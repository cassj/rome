package ROME::Controller::Role;

use strict;
use warnings;
use base 'ROME::Controller::Base';

=head1 NAME

ROME::Controller::Role - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS




=head2 add_to

  Add users to roles.

=cut

sub add_to : Local{
  my($self, $c) = @_;

  unless ($c->check_user_roles('admin')){
    $c->stash->{template} = 'site/access_denied';
    return;
  } 
  
  $c->stash->{template} = 'role/add_to'

}

=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
