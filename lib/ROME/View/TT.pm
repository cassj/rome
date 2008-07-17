package ROME::View::TT;

use strict;
use base 'Catalyst::View::TT';


__PACKAGE__->config({
    CATALYST_VAR => 'Catalyst',
    INCLUDE_PATH => [
        ROME->path_to( 'root', 'skins', ROME->config->{skin} ),
        ROME->path_to( 'root', 'src' ),
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'site/error',
    TIMER        => 0
});

=head1 NAME

ROME::View::TT - Catalyst TTSite View

=head1 SYNOPSIS

See L<ROME>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

