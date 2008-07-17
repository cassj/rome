package ROME::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

# Any ajax response can use the messages template. 
# A single page may have multiple ajax calls and the response div needs
# to have a unique ID, so we initialise a counter here which is incremented
# every time the message div is called.

my $msg_num = 1;

=head1 NAME

ROME::Controller::Root - Root Controller for ROME

=head1 DESCRIPTION

Maps the / root url.

=head1 METHODS

=cut

=head2 default

  Returns a 404, Not found.

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    $c->response->status('404');
    $c->stash->{template} = 'site/404';
}

=head2 index

  If there is no user logged in, redirects the base URL to the login page.
  If there is a current user, the base URL is redirected to the user's account page.

=cut

sub index : Private {
   my ($self, $c) = @_;
   if ($c->user_exists){
     $c->response->redirect($c->uri_for('user/account'))
   }
   else{
     $c->response->redirect($c->uri_for('/user/login'));
   }
}

=head2 auto
    
  Check if there is a user and, if not, forward to login page
    

=cut
    
sub auto : Private {
  my ($self, $c) = @_;
 
  # If a user doesn't exist, force login
  if (!$c->user_exists || $c->user->pending) {
    
    #allow access to login and registration pages.
    if($c->action eq 'user/login' ||
       $c->action eq 'user/register' ||
       $c->action eq 'user/lost_password' ||
       $c->action =~ /^user\/user_confirm/
      ){
      return 1;
    }
    
 
#    #if this is an XMLRPC request, attempt a login.
#    if ($c->req->xmlrpc->is_xmlrpc_request){
#      my $username = $c->request->params->{username} || "";
#      my $password = $c->request->params->{password} || "";
#      unless ($c->login($username, $password)){
#	return 0;
#      }
#    }
    
    
    # if this is an AJAX request, just send a message back.
    # this is to deal with the case when a user's session times out
    # when they have been granted access to a page but before they
    # make an AJAX request.
    if ( $c->request->headers->header('x-requested-with') ){
      $c->response->body('<h3 class="error">Please <a href="'. $c->uri_for('user/login'). '">login</a></h3>');
      return;
    }
    
    # Dump a log message to the development server debug output
    $c->log->debug('***Root::auto User not found, forwarding to /login') if $c->debug;

    # Redirect the user to the login page
    $c->response->redirect($c->uri_for('/user/login'));

    # Return 0 to cancel 'post-auto' processing and prevent use of application
    return 0;
  }
  
  # User found, so return 1 to continue with processing after this 'auto'
  return 1;

}
  



=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {

#sub end : Private{
  my ($self, $c) = @_;

  #if we've got an xml rpc request, don't bother looking for a template.
  #$c->response->body('XMLRPC') if $c->req->xmlrpc->is_xmlrpc_request;

  #the messages template uses a bit of javascript to flash the
  #messages div on update, but you can have multiple instances of the
  #template on a given page, so we just increment a count variable 
  #every time it's used and append that value to the name of the div.
  #and to avoid silly numbers, start at 1 every 100 messages.
  $c->stash->{msg_num} = $msg_num;
  $msg_num = $msg_num == 100 ? 1 : $msg_num+1;
  
 
  # This is just for internal server errors.
  # They get an apology, and an error message if appropriate
  if ( scalar @{ $c->error } && !$c->debug) {
    $c->stash->{errors}   = $c->error;
    $c->stash->{template} = 'site/error';
    $c->error(0);
    $c->response->status('500');
  }
  
  #deal with graphview views
  if(my $view = $c->stash->{graphview}->{view}) {
      $c->detach($view);
  }
  
}


=head2 nav

  An ajax method which returns the navigation bar
  
  The menu is context sensitive, so you need to update it if you 
  make a change in the current user, experiment or datafile without
  a page reload (ie. via an AJAX call)

=cut

sub nav :Local {
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template}='site/nav';
}

=head2 status_bar

  An ajax method which returns the status bar.

=cut

sub status_bar :Local {
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/status_bar';
}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
