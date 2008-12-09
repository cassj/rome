package Bio::Graphics::Glyph::genestructure;

use strict;
use warnings;
use Bio::SeqFeature::Gene::GeneStructure;
use Bio::SeqFeature::Gene::Transcript;

use base 'Bio::Graphics::Glyph::segments';

our $VERSION = 0.1;


# part of the problem with the genestructure stuff is that
# although it stores exons, transcripts etc as seqfeatures,
# it doesn't store them as subfeatures. Probably because it 
# implements sub_SeqFeature instead of get_SeqFeatures
sub draw{
  my $self = shift;
  $self->SUPER::draw(@_);
  my $gd = shift;
}


1;

=head1 NAME

Bio::Graphics::Glyph::genestructure - A glyph for Bio:SeqFeature::Gene::GeneStructures

=head1 SYNOPSIS

  See L<Bio::Graphics::Panel> and L<Bio::Graphics::Glyph> and L<Bio::Graphics::Glyph::segments>.

=head1 DESCRIPTION

This is a subclass of L<Bio::Graphics::Glyph::segments> which will draw
a Bio::SeqFeature::Gene::GeneStructure along with the transcripts within
that structure and their exons, polyA sites and so forth. This is intended
to provide a detailed view of a single GeneStructure and is not advisable for
viewing a large number of genes along a sequence.

This glyph is still in development, however the intention is to have it 
revert to using a simple generic glyph at low zoom and to provide more 
detailed images when zoomed into an individual gene.


=head2 METHODS


=head2 OPTIONS

=head1 BUGS

Please report them.

=head1 SEE ALSO

L<Bio::Graphics::Panel>,
L<Bio::Graphics::Glyph>,
L<Bio::Graphics::Glyph::segment>,
L<Bio::SeqFeatureI>,
L<GD>

=head1 AUTHOR

Cass Johnston E<lt>caroline.johnston@iop.kcl.ac.ukE<gt>.

Copyright (c) 2001 Cass Johnston

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
