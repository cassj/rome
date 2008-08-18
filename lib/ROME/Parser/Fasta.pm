package ROME::Parser::Fasta;

use strict;
use warnings;

use base 'ROME::Parser::Base';

use File::Find::Rule;
use Path::Class;

#make sure this is the version num installed in the db.
our $VERSION = '0.0.1';

=head1 NAME

ROME::Controller::Parser::Fasta

=head1 DESCRIPTION

Subclass of ROME::Controller::Parser to parse Fasta files

=head1 METHODS

=cut

=head2 file_rule

  A File::Find::Rule to locate appropriate files in the upload directory.

=cut

sub file_rule{
  return File::Find::Rule->file->name(   qr/\.fa(sta)?$/i   );
}

=head2 process

Returns the ROMEDB::Process object for the parse_fasta process

=cut

sub process{
  my ($self, $c) = @_;

  #get your process (which should be added to the DB at install)
  my $process = $c->model('ROMEDB::Process')->find
    ({
      name => 'parse_fasta          ',
      component_name =>'parse_fasta          ',
      component_version => __PACKAGE__->VERSION,
     });
  die "parse_fasta process not found in DB" unless $process;
  return $process;
}


=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
