package ROME::View::BioseqPrimer;

use strict;
use base 'Catalyst::View::Bioseq';

use Bio::Location::Simple;
use Bio::Coordinate::Pair;
use Bio::Annotation::ExternalLocation;

#define a coord mapper for the external location annotation
sub coord_mapper{
  my ($self) = @_;

  unless (defined $self->{coord_mapper}){
    my $seq = $self->seq;
    my $annot = $seq->annotation or return undef;
    my ($loc) = $annot->get_Annotations('ExternalLocation') or return undef;
    my $external_loc = Bio::Location::Simple->new(
						  '-start'  => $loc->start,
						  '-end'    => $loc->end,
						  '-strand' => 1,
						 );
    my $seq_loc = Bio::Location::Simple->new(
					     '-start'  => 1,
					     '-end'    => $seq->length,
					     '-strand' => 1,
					    );
    $self->{coord_mapper} = Bio::Coordinate::Pair->new(
						       '-in'  => $seq_loc,
						       '-out' => $external_loc,
						      );
  }
  return $self->{coord_mapper};
}

## Note that all of these need to return either a seq or a coderef
## As per the Bio::Graphics::Panel docs
 
#href for the imap link for a seqfeature

#this isn't going to be flexible enough. Maybe SVG would be easier?
sub imap_link{
  return sub{
    my ($feat, $panel) = @_;
    return 'http://gene' if ($feat->primary_tag eq 'gene');
    return 'http://transcript' if ($feat->primary_tag eq 'transcript');
    return '';
  }
}

sub imap_target{
  my ($feat, $panel) = @_;
  return undef;
}

sub imap_title{
  my ($feat, $panel) = @_;
  return 'this is a test';
}

sub panel_pad_bottom{
  return 20;
}

sub panel_width{
  return 1000;
}

#######
# how to render seqfeats tagged in a particular way:

sub render_gene{
  my ($self, $panel, $feat) = @_;

  #the base class deals with any coord mapping.
  #just draw the thing

  #draw a track for the whole gene region using the
  #genestructure glyph
  $panel->add_track($feat,
		    '-glyph'  => 'arrow',
		    '-linewidth' => 3,
		    '-maxdepth' => 0,
		    '-label'  => 1,
		    '-color'  => 'red',
		   );

  return $panel;
}

sub render_transcript{
  my ($self, $panel, $feat) = @_;

  #draw a track for the transcript
  $panel->add_track($feat,
		    '-glyph'  => 'transcript',
		    '-label'  => 1,
		    '-bgcolor'  => 'yellow',
		   );

  return $panel;
}

#these are all parts of a transcript, don't
#draw them again

#hmm, is there any way of getting these to sit on the same 
#track as the transcript? Yes, of course - they're subfeatures.
sub render_exon{
  my ($self, $panel, $feat) = @_;
  return $panel;
}

sub render_utr3prime{
  my ($self, $panel, $feat) = @_;
  return $panel;
}

sub render_utr5prime{
  my ($self, $panel, $feat) = @_;
  return $panel;
}

sub render_polyA{
  my ($self, $panel, $feat) = @_;
  return $panel;
}

=head1 NAME

ROME::View::BioseqPrimer - Bioseq View for ROME

=head1 DESCRIPTION

Bioseq View for ROME. 

=head1 AUTHOR

=head1 SEE ALSO

L<ROME>

Caroline,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
