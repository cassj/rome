package ROME::Controller::Admin;

use strict;
use warnings;
use base 'ROME::Controller::Base';
use ROME::Constraints;
use File::Find::Rule;
use Path::Class;

=head1 NAME

ROME::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Controller to provide user-related actions: 

=head1 METHODS

=over 2

=cut


=item components

  Matches admin/components

  passes the component management page template
  to the view

=cut

sub components :Local{
  my($self,$c) =@_;
  unless($c->check_user_roles('admin')){
    $c->stash->{template} = 'site/messages';
    $c->stash->{error_msg} = 'Permission Denied. You must be an administrator to view this page';
    return;
  }
  $c->stash->{template} = 'admin/components'
}

=item installable_components

  Ajax method which checks the upload directory for
  installable components and passes the list onto 
  the view to be formatted as a selection list.

=cut
sub installable_components  :Local{

  my ($self, $c) = @_;

  my $rule = File::Find::Rule->file->name( qr/\.rome/i );
  my $upload_dir = dir($c->config->{userdata}, $c->user->username, 'uploads');
  my $files = [$rule->relative->in("$upload_dir")];

  unless ($files){
    $self->stash->{error_msg} = "There are no rome packages in your upload directory.";
    return;
  }

   $c->stash->{uploaded_file_list} = [sort {$a cmp $b } @$files];
}


=item install

  Installs the selected component. 

=cut
sub install  :Local{
  my ($self, $c) = @_;
}


=back

=cut

1;
