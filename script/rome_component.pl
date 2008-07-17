#!/usr/bin/perl

=head1 

  script to create, install and uninstall rome components

=cut

use Getopt::Long;
use Pod::Usage;

my $help  = 0;

GetOptions( 'help|?'=> \$help);

pod2usage(1) if ( $help || !$ARGV[0] );



=head1 NAME

rome_component.pl - Create, Install and Uninstall ROME Components

=head1 SYNOPSIS

rome_component.pl create <component_name>
rome_component.pl install <dir>
rome_component.pl uninstall <component_name>



 Options:
   --help         display this help and exits

 Examples:
   rome_create.pl controller My::Controller
   rome_create.pl -mechanize controller My::Controller
   rome_create.pl view My::View
   rome_create.pl view MyView TT
   rome_create.pl view TT TT
   rome_create.pl model My::Model
   rome_create.pl model SomeDB DBIC::Schema MyApp::Schema create=dynamic\
   dbi:SQLite:/tmp/my.db
   rome_create.pl model AnotherDB DBIC::Schema MyApp::Schema create=static\
   dbi:Pg:dbname=foo root 4321

=head1 DESCRIPTION

Create, install or uninstall a ROME Component. 

=head1 AUTHOR

Cass Johnston 

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
