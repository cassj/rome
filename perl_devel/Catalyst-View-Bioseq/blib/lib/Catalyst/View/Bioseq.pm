package Catalyst::View::Bioseq;

use strict;
use base qw/Catalyst::View/;
use Bio::Seq;
use Bio::Graphics;
use Bio::SeqFeature::Generic;
use Bio::Coordinate::Pair;
use Bio::Location::Simple;

our $VERSION = '0.27';

=head1 NAME

Catalyst::View::Bioseq - Bioperl Bio::Seq View Class

=head1 SYNOPSIS

# use the helper to create your View
    myapp_create.pl view Bioseq Bioseq

# render view from lib/MyApp.pm or lib/MyApp::C::SomeController.pm

    sub message : Global {
        my ( $self, $c ) = @_;
        $c->stash->{bioseqview}->{seq} = $bioseq;
        $c->forward('MyApp::View::Bioseq');
    }

=cut


sub seq {
  my $self = shift;
  if (scalar @_){
    $self->{seq} = shift;
  }
  return $self->{seq};
}

sub process {
    my ( $self, $c ) = @_;

    # grab the seq
    my $seq = $c->stash->{bioseqview}->{seq};

    # make sure we've got it
    unless (defined $seq) {
        $c->log->debug('No Bio::Seq specified for rendering') if $c->debug;
        return 0;
    }

    # and that it really is a Bioseq
    unless ($seq->isa('Bio::Seq')){
      my $error = 'Sequence is not a Bio::Seq';
      $c->log->error($error);
      $c->error($error);
      return 0;
    }

    $self->seq($seq);

    #render will set error messages if it fails so just bail
    #if we don't get anything back
    return $self->render($c) ? 1:0;
}


sub render {
  my ($self, $c) = @_;
  
  my $seq = $self->seq;
  
  #are we expected to map to a different location?
  my $mapper = $self->coord_mapper;

  my $loc = Bio::Location::Simple->new(
				       '-start'=> 1, 
				       '-end'=> $seq->length, 
				       '-strand'=>1 
				      );
  $loc = $mapper->map($loc) if $mapper;

  #build a Bio::Graphics::Panel from seq
  my $panel = Bio::Graphics::Panel->new
    (
     '-width'        => $self->panel_width,
     '-start'        => $loc->start,
     '-end'          => $loc->end,
     '-pad_left'     => $self->panel_pad_left($seq),
     '-pad_right'    => $self->panel_pad_right($seq),
     '-pad_bottom'   => $self->panel_pad_bottom($seq),
     '-pad_top'      => $self->panel_pad_top($seq),
    );

  #create a generic seqfeature for the scale
  my $full_seq = Bio::SeqFeature::Generic->new
    (
     '-start'        => $loc->start,
     '-end'          => $loc->end,
     '-display_name' => $seq->display_name,
    );

  #add it to the panel as a scale
  $panel->add_track(
		    $full_seq,
		    '-glyph'  => 'arrow',
		    '-bump'   => 0,
		    '-double' => 1,
		    '-tick'   => 2,
		    '-name'   => 'ladder',
		   );


  #and as the actual sequence
  $panel->add_track(
		    $full_seq,
		    '-glyph'  => 'generic',
		    '-label'  => 1,
		    '-name'   => 'full_seq',
		   );


  #sort features up by their primary tag and render
  my $feats = {};
  foreach ($seq->get_SeqFeatures){
    #storable file, which doesn't appear to load up all the
    #classes we need, so we have to do it by hand.
    my $class = ref $_;
    eval "require $class";
    push @{$feats->{$_->primary_tag}}, $_;
  }

  foreach (keys %$feats){
    $self->add_feats($panel, $_, $feats)
  }

  #and render it appropriately, setting the content type
  my $type = $c->stash->{bioseqview}->{type} || 'png';
  
  if ($type eq 'png'){
    $c->response->body($panel->png);
    $c->response->content_type('image/png');
  }
  elsif ($type eq 'imap'){
    my $mapname = $c->stash->{bioseqview}->{mapname} || 'bioseq';
    $c->response->body($panel->create_web_map
		       (
			$mapname,
			$self->imap_link,
			$self->imap_title,
			$self->imap_target
		       )); 
    $c->response->content_type('text/html');
  }
  #possibly also deal with jpeg? svg? 

  return 1;
}



# add the seq features to the panel
sub add_feats{
  my ($self, $panel, $tagname, $sorted_feats) =  @_;

   #get a position mapper
  my $mapper = $self->coord_mapper;

  #grab the features with this tagname
  my $feats = $sorted_feats->{$tagname};
  return $panel unless ref $feats eq 'ARRAY';

  #if we're mapping to another coord sys, make sure we
  #map the features
  if ($mapper){
    foreach (@$feats){
      my $loc = Bio::Location::Simple->new(
					   '-start'  => $_->start, 
					   '-end'    => $_->end, 
					   '-strand' => $_->strand, 
					  );
      $loc = $mapper->map($loc) if $mapper;
      $_->start($loc->start);
      $_->end($loc->end);
    }
  }

  #if we've got a render_<tagname> method, then use that to draw the track
  my $method_name = "render_$tagname";
  if ($self->can($method_name)){
    $self->$method_name($panel,$feats);
  }

  #otherwise, just draw a generic feature
  else{
    $panel->add_track($feats,
		      '-glyph'  => 'generic',
		      '-label'  => 1,
		     );
    }

  return $panel;
}


#an optional Bio::Coordinate::Pair capable of mapping
#the sequence positions to another set of coords
#override this in particular views if you want 
sub coord_mapper{
  return undef;
  
}



### Imagemap Settings ###

# These should be overridden in view subclasses
# to return the appropriate string or coderef
# for the feature in question.
# See Bio::Graphics::Panel for details
sub imap_link{
  return sub{
    my ($feature, $panel) = @_; 
    return '';
  };
}
sub imap_title{
  return sub{
    my ($feature, $panel) = @_;
    return '';
  }
}
sub imap_target{
  return sub{
    my ($feature, $panel) = @_;
    return '';
    };
}


### Bio::Graphics::Panel settings ###

#width of the panel. Override in subclass if you like.
sub panel_width{
 my ($self, $seq) = @_;
 return 800;
}

#These are calculated automatically
#length of sequence segment in bp
#sub panel_length{
# my ($self, $seq) = @_;
#  return $seq->length;
#}
#start of range, in 1 based coords
#sub panel_start{
# my ($self, $seq) = @_;
# return $seq->start;
#}
#
##end of range in 1 based coords
#sub panel_stop{
# my ($self, $seq) = @_;
# return $seq->end;
#}

#base pair to place at extreme left of image (zero based coords)
sub panel_offset{ 
  my ($self, $seq) = @_;
  return undef;
}

#spacing between tracks, in pixels
sub panel_spacing{
  my ($self, $seq) = @_;
  return undef;
}
#whitespace between sides of image and contents (px)
sub panel_pad_top{
  my ($self, $seq) = @_;
  return undef;
}
sub panel_pad_bottom{
  my ($self, $seq) = @_;
  return undef;
}
sub panel_pad_left{
  my ($self, $seq) = @_;
  return 10;
}
sub panel_pad_right{
  my ($self, $seq) = @_;
  return 10;
}
#background color for the panel as a whole
sub panel_bgcolor{
  my ($self, $seq) = @_;
  return undef;
}
#background color for the key to the panel
sub panel_key_color{
  my ($self, $seq) = @_;
  return undef;
}
#spacing between key glyps
sub panel_key_spacing{
  my ($self, $seq) = @_;
  return undef;
}
#font to use in key captions
sub panel_key_font{
  my ($self, $seq) = @_;
  return undef;
}
#where to print key (bottom, between, left, right, none)
sub panel_key_style{
  my ($self, $seq) = @_;
  return undef;
}
#whether to add the category to the track key
sub panel_add_category_labels{
  my ($self, $seq) = @_;
  return undef;
}
#if 'left' or 'right' keys are in use, then this will autocalc padding
sub panel_auto_pad{
  my ($self, $seq) = @_;
  return undef;
}
#what to do with empty tracks ('suppress, 'key', 'line', 'dashed')
sub panel_empty_tracks{
  my ($self, $seq) = @_;
  return undef;
}
#flip the coords left to right (eg for -ve strand features)
sub panel_flip{
  my ($self, $seq) = @_;
  return undef;
}
#whether to invoke callbacks on the auto 'track' and 'group glyphs
#sub panel_all_callbacks{}
#whether to draw a vertical grid. Expects a scalar true value to have
#grid at regular intervals or an array of positions
sub panel_grid{
  my ($self, $seq) = @_;
  return undef;
} 
#grid color
sub panel_gridcolor{
  my ($self, $seq) = @_;
  return undef;
}
#extend grid into pad regions
sub panel_extend_grid{
  my ($self, $seq) = @_;
  return undef;
}
#an image to use for the background (under grid)
sub panel_background{
  my ($self, $seq) = @_;
  return undef;
}
#an image to use for the backgroud (over grid)
sub panel_postgrid{
  my ($self, $seq) = @_;
  return undef;
}
#create a truecol (24bit) image
sub panel_truecolor{
  my ($self, $seq) = @_;
  return undef;
}

#needs to be set to GD::SVG for SVG images
#defaults to vanilla GD
#sub panel_image_class{
#  my ($self, $seq) = @_;
#  return undef;
#}




1;

__END__

=head1 DESCRIPTION

This is the Catalyst view class for Bioperl L<Bio::Seq> objects.
Your application should defined a view class which is a subclass of
this module.  The easiest way to achieve this is using the
F<myapp_create.pl> script (where F<myapp> should be replaced with
whatever your application is called).  This script is created as part
of the Catalyst setup.

    $ script/myapp_create.pl view Bioseq Bioseq

This creates a MyApp::View::Bioseq.pm module in the F<lib> directory (again,
replacing C<MyApp> with the name of your application) which looks
something like this:

    package FooBar::View::Bioseq;
    
    use strict;
     use base 'Catalyst::View::Bioseq';

    __PACKAGE__->config->{DEBUG} = 'all';

Now you can modify your action handlers in the main application and/or
controllers to forward to your view class.  You might choose to do this
in the end() method, for example, to automatically forward all actions
which have $c->stash->{bioseqview}->{seq} defined to this view

# In MyApp::Controller::Root

  if($c->stash->{bioseqview}->{seq}){
      my $view = $c->stash->{bioseqview}->{view} || 'MyApp::View::Bioseq';
      $c->forward($view);
  } 



By default, output is PNG. You can, in theory, select anything that GD can handle, but
I haven't tested it for anything other than PNG yet. Output type can be specified in 
$c->stash->{bioseqview}->{type}


=head2 METHODS

=head2 new

The constructor for the TT view. Sets up the template provider, 
and reads the application config.

=head2 process

Renders the template specified in C<< $c->stash->{template} >> or
C<< $c->action >> (the private name of the matched action.  Calls L<render> to
perform actual rendering. Output is stored in C<< $c->response->body >>.


=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Helper::View::Bioseq>,
L<Bio::Seq>, L<Bio::Graphics>

=head1 AUTHORS

Caroline Johnston, C<johnston@biochem.ucl.ac.uk>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it 
under the same terms as Perl itself.

=cut
