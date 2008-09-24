package Catalyst::Helper::View::Bioseq;

use strict;

=head1 NAME

Catalyst::Helper::View::Bioseq - Helper for Bioseq Views

=head1 SYNOPSIS

    script/create.pl view Bioseq Bioseq

=head1 DESCRIPTION

Helper for Bioseq Views.

=head2 METHODS

=head3 mk_compclass

=cut

sub mk_compclass {
    my ( $self, $helper ) = @_;
    my $file = $helper->{file};
    $helper->render_file( 'compclass', $file );
}

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Request>,
L<Catalyst::Response>, L<Catalyst::Helper>

=head1 AUTHOR

Caroline Johnston, C<johnston@biochem.ucl.ac.uk>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;

__DATA__

__compclass__
package [% class %];

use strict;
use base 'Catalyst::View::Bioseq';


=head1 NAME

[% class %] - Bioseq View for [% app %]

=head1 DESCRIPTION

Bioseq View for [% app %]. 

=head1 AUTHOR

=head1 SEE ALSO

L<[% app %]>

[% author %]

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
