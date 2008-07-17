package ROME::Controller::User;

use strict;
use warnings;
use base 'ROME::Controller::Base';
use ROME::Constraints;

use Digest::SHA1  qw(sha1);
use MIME::Lite::TT::HTML;

__PACKAGE__->mk_accessors(qw/user/);



=head1 NAME

ROME::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Controller to provide user-related actions: 

=head1 METHODS

=cut


#=head2 index
#
#  Response for ../user 
#  detaches to login
#
#=cut
#
#sub index:Private{
#  my($self,$c) =@_;
#
#  $c->detach('login');
#}


=head2 /user/login

  Requires SSL if enabled in rome.yml.
  Generates a login form
  Processes submission of the login form, 
  authenticating (or not) the user.
  

=cut

sub login : Local {
  my ($self, $c) = @_;

  #ssl if we're supposed to
  if ($c->config->{require_ssl}->{enable}) {
    $c->require_ssl;
  }

  #have we got submitted params?
  if ($c->request->params->{submit}) {

    #check they're valid
    if ($c->forward('_validate_login_params')){
 
      # Attempt to log the user in
      my $username = $c->request->params->{username} || "";
      my $password = $c->request->params->{password} || "";
      if ($c->login($username, $password)) {
	# If successful, then let them use the application
  	$c->stash->{template} = 'user/login_successful.tt2';
	return 1;
      } else {
	# Set an error message
	$c->stash->{error_msg} = "Bad username or password.";
      }

    }

  }

  # If either of above don't work out, send to the login page
  $c->stash->{template} = 'user/login.tt2';
}



#private method to check login parameters
sub _validate_login_params : Private{
  my ($self, $c) = @_;

  my $dfv_profile = {
		     msgs => {
			      constraints => {
					      'user_exists'   => 'User not found.',
					      'allowed_chars' => 'Valid usernames may only contain letters, numbers and underscores.',
					     },
			      format => '%s',
			     },
		     required => [qw(username password)],
		     optional => [qw(forename surname institution address)],
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    username => [
							 ROME::Constraints::user_exists($c),
							 ROME::Constraints::allowed_chars,
							],

					   }
		    };
  
  $c->form($dfv_profile);

}

=head2 /user/logout
  
  Logout the current user.

=cut
    

sub logout : Local {
  my ($self, $c) = @_;

  #logout the user
  $c->logout;  
  
  #return the login page.
  $c->stash->{status_msg} = 'You have been logged out.';
  $c->detach('login');

}
  

=head2 /user/register

  register a new user.  

=cut

sub register : Local{
  my ($self, $c) = @_;

  #enable SSL if configured
  if ($c->config->{require_ssl}->{enable}) {
    $c->require_ssl;
  }

  # has the form been submitted?
  if($c->request->params->{submit}){

     $c->forward('_validate_registration_params');

     if ($c->form->success()){
       $c->detach('_process_registration');
     }

  }

  # If the form hasn't been submitted, return the form.
  $c->stash->{template} = 'user/register.tt2';
}





#Private method, called by register to check the user input using d:fv plugin
sub _validate_registration_params : Private {
    my ($self, $c) = @_;

    my $dfv_profile = {
 	msgs => {
	    constraints => {
		'user_exists'        => 'That username is already taken.',
		'allowed_chars'      => 'Please use only letters and numbers in this field',
		'strings_match'      => "Your passwords don't match.",
		'valid_email'        => "Not a valid email address.",
		'allowed_chars_plus' => "Please use only letters, numbers and spaces in this field",
	    },
	    format => '%s',
	},
        required => [qw(username password password2 email)],
        optional => [qw(forename surname institution address)],
        filters => ['trim'],
        missing_optional_valid => 1,    
        constraint_methods => {
			       username => [
					    ROME::Constraints::not_user_exists($c),
					    ROME::Constraints::allowed_chars,
					   ],
			       
			       password => [
					    ROME::Constraints::strings_match('password2'),
					   ],
			       forename   => ROME::Constraints::allowed_chars,
			       surname    => ROME::Constraints::allowed_chars,
			       institution=> ROME::Constraints::allowed_chars_plus,
			       address    => ROME::Constraints::allowed_chars_plus,
			       email      => ROME::Constraints::valid_email,
			     },
		      };


    $c->form($dfv_profile);  
}




# Private method
#    forwards to_insert_user_into_db
#    Checks config for registration->{user_confirm} and registration->{admin_confirm}. 
#    Calls _user_email_confirm and _admin_email_confim as required and sets the user_approved and admin_approved flags
#    for the new user. 
#    forwards to ->_complete_registration

sub _process_registration : Private {
    my ($self, $c) = @_;

    $c->forward('_insert_user_into_db');
  
    #if we need confirmation from the user
    if ($c->config->{registration}->{user_confirm}) {
      #email request for confirmation
      $c->forward('_user_email_confirmation');
    }
    else{
      $self->user->user_approved('1');
    }
    
    #if we need confirmation from the admin?
    if ($c->config->{registration}->{admin_confirm}) {
      #email request for confirmation
      $c->forward('_admin_email_confirmation');
    }
    else{
	$self->user->admin_approved('1');
    }

    $self->user->update;

    #attempt to complete registration
    $c->forward('_complete_registration');
    
    return $c;
}


### crap this should be add in person. surely. 

# Private Method
# Inserts a new user into the database
sub _insert_user_into_db : Private
{
    my ($self, $c) = @_;

    #get today's date.
    my ($day, $month, $year) = (localtime)[3,4,5];
    $year = $year+1900;
 
    #create a random key for this registration to prevent people being 
    #registered without their permission.
    my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9 );
    my $email_id = join("", @chars[ map { rand @chars } ( 1 .. 10 ) ]);

    #insert new user into person 
    my $new_user = $c->model('ROMEDB::Person')->create(
                             {
			      forename     => $c->req->param('forename')                       || '',
			      surname      => $c->req->param('surname')                        || '',
			      institution  => $c->req->param('institution')                    || '',
			      address      => $c->req->param('address')                        || '',
			      username     => $c->req->param('username'),
			      email        => $c->req->param('email'),
			      password     => sha1($c->config->{authentication}->{dbic}->{password_pre_salt}
						   .$c->req->param('password')
						   .$c->config->{authentication}->{dbic}->{password_post_salt}), 
			      created      => "$year-$month-$day",      
			  } );

    #check your new user and store it somewhere handy
    die("Failed to add new user to the database") unless ($new_user->username);
    $self->user($new_user);

    #create a related person_pending object.
    my $new_pending = $c->model('ROMEDB::PersonPending')->create({
								  username  => $self->user->username,
								  email_id  => $email_id,
								 });
    die("Failed to add new person_pending for user". $new_user->username) unless $new_pending->username;

    $self->user->update;

    return 1;

}

# Private Method
#    emails the user for confirmation of the registration request. 
#Gives them a link to the register/user_confirm page with args.
sub _user_email_confirmation : Private
{
    my ($self, $c) = @_;
    
    #erm, really?
    die "Missing user" unless $self->user;

    #build the link
    my $link = $c->uri_for('/user/user_confirm')
	      .'/'
	      .$self->user->username
              .'/'
	      .$self->user->email_id;
 
    #build the message
    my $msg = MIME::Lite::TT::HTML->new(
		From => 'no-reply',
		To => $self->user->email,
		Subject => 'Confirmation of Registration',
		Template => {text =>'user_email_confirm.tt',
			     html => 'user_email_confirm.html.tt'
			    },
		TmplParams => {user => $self->user,
			       link => $link
			      }, 
		TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},

               );
    
    $msg->send();

    return 1;
}

=head2 /user/user_confirm

Linked to from the user's confirmation of registration email.
When accessed, with the correct key from the email,
this will verify the user's account, unless still waiting
for admin confirmation.

=cut


#sets $self->person_pending, 
#sets user approval flag to 1 and calls _complete_registration
sub user_confirm : Local
{
    my ($self, $c, $username, $email_id) = @_;

    #check your params.
    unless ($username && $email_id){
      $c->stash->{error_msg} = "Invalid account confirmation. Please check your URL.";
      $c->stash->{template} = "user_error.tt2";
      return;
    }

    #retrieve the pending user
    my $user = $c->model('ROMEDB::Person')->find($username);
    
    #stop if we couldn't find the user
    unless ($user->username){
      $c->stash->{error_msg} = "Your registration details were not found. Please check your URL.</br>"
	                     . "If it has been over a week since you registered, they may have been deleted.";
      $c->stash->{template} = "user_error.tt2";
      return;
    }

    #stop if the email_id given isn't the same as the one in the DB.
    unless ($email_id eq $user->email_id){
      $c->stash->{error_msg} = "Problem with registration confirmation. Please check your URL";
      $c->stash->{template} = "user_error.tt2";
      return;
    }

    #record user approval.
    $user->user_approved('1');
    $user->update;
    $self->user($user);

    #attempt to complete registration
    $self->_complete_registration($c);

}


#private action called (if set in rome.yml) to send an email
#to the admin to confirm a new user registration.
sub _admin_email_confirmation : Private
{
    my ($self, $c) = @_;
    
    die "no user" unless $self->user->username;

    #build the link
    my $link = $c->uri_for('/user/admin_confirm')
	      .'/'
	      .$self->user->username
              .'/'
	      .$self->user->email_id;


    #build the message
    my $msg = MIME::Lite::TT::HTML->new(
		From => 'no-reply',
		To => $c->config->{admin_email},
		Subject => 'Confirmation of Registration',
		Template => {text =>'admin_email_confirm.tt',
			     html => 'admin_email_confirm.html.tt'
			    },
		TmplParams => {user  => $self->user,
			       link => $link
			      }, 
		TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},

               );
    
    $msg->send();

}


=head2 /user/admin_confirm

Linked to by the admin confirmation of registration email.
When accessed, with the correct key from the email,
this will verify the user's account, unless still waiting
for user confirmation.

=cut

# sets $self->person_pending 
# sets admin approval flag to 1
# calls _complete_registration
sub admin_confirm : Local 
{
    my ($self, $c, $username, $email_id) = @_;

    #check current user has admin role.

    #check your params.
    unless ($username && $email_id){
      $c->stash->{error_msg} = "Invalid account confirmation. Please check your URL.";
      $c->stash->{template} = "user_error.tt2";
      return;
    }

    #retrieve the pending user
    my $user = $c->model('ROMEDB::Person')->find($username);
    
    #stop if we couldn't find the user
    unless ($user->username){
      $c->stash->{error_msg} = "Registration details for user $username were not found. Please check your URL.</br>"
	                     . "If it has been over a week since registration, they may have been deleted.";
      $c->stash->{template} = "user_error.tt2";
      return;
    }

    #stop if the email_id given isn't the same as the one in the DB.
    unless ($email_id eq $user->email_id){
      $c->stash->{error_msg} = "Problem with registration confirmation. Please check your URL";
      $c->stash->{template} = "user_error.tt2";
      return;
    }

    #record admin approval
    $user->admin_approved('1');
    $user->update;
    $self->user($user);
    
    #attempt to complete registration.
    $self->_complete_registration($c);

}

# Private method
#   checks that the user and admin approval flags are 1
#   then removes the person_pending.
sub _complete_registration : Private
{
    my ($self, $c) = @_;

    die "Trying to complete registration with no user" 
	unless $self->user->username;

    $c->stash->{username} = $self->user->username;

    unless ($self->user->user_approved){
      $c->stash->{user} = $self->user;
      $c->stash->{template} = 'user/awaiting_user_approval.tt2';
      return;
    }
    unless ($self->user->admin_approved){
      $c->stash->{template} = 'user/awaiting_admin_approval.tt2';
      return;
    }

    #delete the person_pending 
    #for some reason if I try and do this with person->pending->delete it removes the person too
    my $pending = $c->model('PersonPending')->find($self->user->username);
    $pending->delete;
    
    #confirm to the user
    $self->_email_completion($c);
    $c->stash->{user} = $self->user->username;
    $c->stash->{template} = 'user/registration_success.tt2';
}

#email the user to confirm their registration
sub _email_completion{
  my ($self, $c) = @_;
  
  die "Trying to _email_completion with no user in $self->user" 
    unless $self->user;

    #build the message
    my $msg = MIME::Lite::TT::HTML->new(
		From => 'no-reply',
		To => $self->user->email,
		Subject => 'Confirmation of Registration',
		Template => {text =>'welcome.tt',
			     html => 'welcome.html.tt'
			    },
		TmplParams => {user  => $self->user,
			       admin_email => $c->config->{admin_email},
			       link => $c->uri_for('/user/login'),
			      }, 
		TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},

               );
    
    $msg->send();

}





=head2 /user/account

  returns the user's account page.

=cut

sub account : Local {
  my ($self, $c) = @_;
  
  # send to the account page.
  $c->stash->{template} = 'user/account.tt2';
  
}


=head2 

  Update users account details.
  This is an ajax method, called from a form

=cut
  
sub account_update :Path('account/update'){

  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'messages.tt2';  

  #check the form params
  if ($c->forward('_validate_account_params')){
    #alter the account details, as requested.
    $c->user->forename($c->request->params->{forename});
    $c->user->surname($c->request->params->{surname});
    $c->user->email($c->request->params->{email});
    $c->user->institution($c->request->params->{institution});
    $c->user->address($c->request->params->{address});
    $c->user->update;
    $c->stash->{status_msg} = 'Your account details have been updated.';
  }

}



#checks the parameters from the update
sub _validate_account_params : Private{
    my ($self, $c) = @_;

    my $dfv_profile = {
 	msgs => {
	    constraints => {
		'valid_email'        => "Not a valid email address.",
		'allowed_chars'      => "Please use only letters and numbers in this field.",
		'allowed_chars_plus' => 'Please use only letters, numbers, commas or spaces in this field',
		'user_exists' => 'Username not found.',
	    },

	    format => '%s',
	},
        required => [qw(username)],
        optional => [qw(email forename surname institution address)],
        filters => ['trim'],
        missing_optional_valid => 1,    
        constraint_methods => {
			       email => ROME::Constraints::valid_email,
			       forename => ROME::Constraints::allowed_chars,
			       surname => ROME::Constraints::allowed_chars,
			       address => ROME::Constraints::allowed_chars_plus,
			       institution => ROME::Constraints::allowed_chars_plus,
			       username => ROME::Constraints::user_exists($c),
			      },
		      };

    $c->form($dfv_profile);  
}


=head2 reset_password

Returns the change password form and processes its submission.
Logs the user out, changes their password and logs them back in.

=cut

sub reset_password : Local{
  my ($self, $c) = @_;

  #ssl if we're supposed to
  if ($c->config->{require_ssl}->{enable}) {
    $c->require_ssl;
  }

  #have we got submitted params?
  if ($c->request->params->{submit}) {

    #check the form params
    if ($c->forward('_validate_password_params')){

      #make the new password
      my $newpw =  sha1($c->config->{authentication}->{dbic}->{password_pre_salt}
			.$c->req->param('password')
			.$c->config->{authentication}->{dbic}->{password_post_salt});
      
      #logout the user
      $c->logout;
      
      #get the user object and reset the password.
      my $user = $c->model('ROMEDB::Person')->find($c->request->params->{username});
      $user->password($newpw);
      $user->update;

      #log them back in again.
      my $username = $c->request->params->{username} || "";
      my $password = $c->request->params->{password} || "";
      if ($c->login($username, $password)) {      
	$c->stash->{ajax} = 1;
	$c->stash->{template} = 'messages.tt2';  
	$c->stash->{status_msg} = 'Your password has been reset.';
	return 1;
      }
      else {
	# If there are problems, send them back to the login and apologise
	$c->stash->{error_msg} = 'Sorry, there was a problem resetting your password. If you cannot login, contact '.$c->config->{admin_email};
	$c->stash->{template} = 'user/login.tt2';
	return 1;
      }
    }
  }

  #otherwise, return the form
  $c->stash->{template} = 'user/reset_password.tt2';

}


# private action to validate password change params
sub _validate_password_params :Private {
   my ($self, $c) = @_;

   my $dfv_profile = {
      msgs => {
	    constraints => {
		'strings_match'      => "Your passwords don't match.",
		'user_exists'        => 'Username not found',
	    },
	    format => '%s',
	},
        required => [qw(username password password2)],
        filters => ['trim'],
        constraint_methods => {
			       username => [
					    ROME::Constraints::user_exists($c),
					   ],
			       
			       password => ROME::Constraints::strings_match('password2'),
			     },
		      };

    $c->form($dfv_profile);  


}

=head2 lost_password

 Returns the lost_password form and processes its submissions.
 emails the username with a new, randomly generated password 
 which can be changed when they log back in.

=cut

sub lost_password : Local{
   my ($self, $c) = @_;

   #have we got submitted params?
   if ($c->request->params->{submit}) {

   #set ajax response
   $c->stash->{ajax} = 1;
   $c->stash->{template} = 'messages.tt2';    
     
     #check the form params
     if ($c->forward('_validate_lost_password_params')){
       
       #make the new password
       my @chars = ( "A" .. "Z", "a" .. "z", 0 .. 9 );
       my $pw = join("", @chars[ map { rand @chars } ( 1 .. 8 ) ]);

       my $encpw =  sha1($c->config->{authentication}->{dbic}->{password_pre_salt}
			 .$pw
			 .$c->config->{authentication}->{dbic}->{password_post_salt});
       
       #get the user and set the pw
       my $user = $c->model('ROMEDB::Person')->find($c->request->params->{username});
       $user->password($encpw);
       $user->update;

       #send the password to the user
       my $msg = MIME::Lite::TT::HTML->new(
		From => 'no-reply',
		To => $user->email,
		Subject => 'ROME password',
		Template => {text =>'new_pass.tt',
			     html => 'new_pass.html.tt'
			    },
		TmplParams => {user        => $user,
			       password    => $pw,
			       admin_email => $c->config->{admin_email},
			       link        => $c->uri_for('/user/login'),
			      }, 
		TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
       );
       
       $msg->send();
       
       $c->stash->{status_msg} = 'Your new password will be sent to your registered email address';
       return 1;
     }
     else {
       # If there are problems, send them back to the login and apologise
       $c->stash->{error_msg} = 'Sorry, there was a problem resetting your password. Contact '.$c->config->{admin_email};
       return 1;
     }
   }
   
   $c->stash->{template} = 'user/lost_password.tt2';
 }


# private action to validate lost_password params
sub _validate_lost_password_params :Private {
   my ($self, $c) = @_;

   my $dfv_profile = {
      msgs => {
	    constraints => {
		'user_exists'        => 'Username not found',
	    },
	    format => '%s',
	},
        required => [qw(username)],
        filters => ['trim'],
        constraint_methods => {
			       username => ROME::Constraints::user_exists($c),
			     },
		      };

    $c->form($dfv_profile);  


}





=head2 set_experiment

  AJAX method to set the current user's current experiment.
  The only parameter is the experiment name and owner eg
  set_experiment?name=some_experiment&owner=some_owner

  The result is a message saying that the expt has been updated. 
  It also contains some js to update the menu and status bar.

  Note that this will also remove any selected datafiles.

=cut

sub set_experiment :Local{
  my ($self, $c, $name, $owner) = @_;

  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';

  $c->request->params->{name} = $name if $name;
  $c->request->params->{owner} = $owner if $owner;
  
  #check params
  if($c->forward('_validate_set_experiment')){

    my $experiment = $c->model('ROMEDB::Experiment')->find($c->request->params->{name}, $c->request->params->{owner});

    #check permissions
    my $access_granted = 0;

    #experiment belongs to the user, is public or user is admin
    $access_granted = 1 if (
	$experiment->owner->username eq $c->user->username 
	|| $experiment->status eq 'public'
	|| $c->check_user_roles('admin')
	);

    #experiment is shared and user has workgroup?
    if($experiment->status eq 'shared'){

      #lookup table of user workgroups
      my $rs = $c->user->workgroups; 
      my $person_wgs={};
      while(my $wg = $rs->next){
	$person_wgs->{$wg->name} = 1;
      } 
      #check experiment workgroups.
      $rs = $experiment->workgroups;
      while (my $e_wg = $rs->next){
	$access_granted = 1 if $person_wgs->{$e_wg->name};
      }
    }


    if($access_granted){
	$c->user->experiment($experiment);

	while (my $sd = $c->user->selected_datafiles->next){
	  $sd->delete;
	}

	$c->user->update;
	$c->stash->{status_msg} = 'set experiment '.$experiment->name;
    }
    else{
      $c->stash->{error_msg} = "You don't have permission to set that experiment.";
    }
  }
  
}

#validates owner and name for setting experiment
sub _validate_set_experiment :Private{
 
my ($self, $c) = @_;

  my $dfv_profile = {
		     required => [qw(name owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
				     user_exists        =>
					      'That user does not exist.',
				     experiment_exists  =>
					      'That experiment does not exist',
					     },
			     },
		     filters => ['trim'],
		     constraint_methods => {
					    owner => ROME::Constraints::user_exists($c),
					    name  => ROME::Constraints::experiment_exists($c,'owner'), 
					   },
		    };
  $c->form($dfv_profile);

}



=head2 workgroup_member_autocomplete

  Returns a list of workgroups to which the current user is a member
  for use in ajax autocompletes

  Param is workgroup_name

=cut

sub workgroup_member_autocomplete : Path('workgroup/autocomplete_member') {

  my ($self, $c) = @_;
  my $val = $c->request->params->{workgroup_name} || '.*';
  $val = '.*' if $val eq '*';



  my %complete_list =  map {$_->name => $_->description}
                          grep {$_->name =~/$val/}
			    $c->user->workgroups;
  
  $c->stash->{ajax} = "1";
  $c->stash->{template}='scriptaculous/autocomplete_list.tt2';
  $c->stash->{complete_list}= \%complete_list;
}





=head2 workgroup_leader_autocomplete

  Returns a list of workgroups of which the current user is leader
  for use in ajax autocompletes

  Param is workgroup_name

=cut

sub workgroup_leader_autocomplete : Path('workgroup/autocomplete_leader') {

  my ($self, $c) = @_;
  my $val = $c->request->params->{workgroup_name} || '.*';
  $val = '.*' if $val eq '*';

  my %complete_list =  map {$_->name => $_->description} 
                          grep {($_->leader->username eq $c->user->username) && ($_->name =~/$val/)}
			    $c->user->workgroups;
 
  
  $c->stash->{ajax} = "1";
  $c->stash->{template}='scriptaculous/autocomplete_list.tt2';
  $c->stash->{complete_list}= \%complete_list;
}


=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
