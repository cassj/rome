package ROME::View::BioseqPrimer;

use strict;
use base 'Catalyst::View::Bioseq';

use Bio::Location::Simple;
use Bio::Coordinate::Pair;
use Bio::Annotation::ExternalLocation;

#we want to define a coord mapper for the external location
#annotation
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
sub imap_link{
  return sub{
    my ($feat, $panel) = @_;
    return 'http://www.google.com' if (ref($feat) eq 'Bio::SeqFeature::Gene::GeneStructure');
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



###### Some generic seqfeature display methods

#MOVE TO BASE CLASS WHEN WORKING.

#Define a specific render method for SeqFeature::Gene::GeneStructure 
#features
sub render_genestructure{
  my ($self, $panel, $feat) = @_;

  #the base class deals with any coord mapping.
  #just draw the thing.
  
  #draw a track for the whole gene region
  $panel->add_track($feat,
		    '-glyph'  => 'generic',
		    '-label'  => 1,
		    '-bgcolor'  => 'red',
		   );
  
  #and add transcript features as a box

  #fill transript box with exons

  #what about UTR? PolyA etc.

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
