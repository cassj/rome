package ROME::Parser::Base;

use strict;
use warnings;

use File::Find::Rule;
use Module::Find;
use Path::Class;

=head1 NAME

ROME::Parser::Base

=head1 DESCRIPTION

Base class for ROME parsers.

=head1 METHODS

=over 2

=cut

=item new

=cut
sub new{
  my $self = bless {}, shift;
  $self->{context} = shift or die "no context supplied";
  return $self;
}

=item context

=cut
sub context{
  my $self = shift;
  return $self->{context};
}

=item file_rule

  Should return a File::Find::Rule which can pick out the 
  valid files in the upload directory.
  This should be overridden by subclasses.

=cut
sub file_rule{
  return File::Find::Rule->file;
}

=item valid_files

  returns a reference to an array of all the uploaded files valid
  for this parser, as defined by __PACKAGE__->file_rule.

=cut

sub valid_files {
    my $self = shift;
    my $rule = $self->file_rule;
    my $upload_dir = dir($self->context->config->{userdata},$self->context->user->username,'uploads');
    my @files = $rule->relative->in("$upload_dir");
    return \@files;
}


=back

=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
