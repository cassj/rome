package ROME::Controller::Workgroup;

use strict;
use warnings;
use base 'ROME::Controller::Base';
use ROME::Constraints;

use MIME::Lite::TT::HTML;


=head1 NAME

ROME::Controller::Workgroup - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

   matches /workgroup

   Returns the workgroup admin page.

=cut

sub index : Private{
  my ($self, $c) = @_;

  #return an admin GUI page 
  my @workgroups = $c->user->workgroups;
  my @workgroups_led = $c->user->workgroups_led;
  
    
  $c->stash->{workgroups_member} = \@workgroups;
  $c->stash->{workgroups_led}= \@workgroups_led;


  my @pending_joins = $c->model('ROMEDB::WorkgroupJoinRequest')->search(person=>$c->user->username);
  $c->stash->{pending_joins} = \@pending_joins if scalar(@pending_joins);

  use Data::Dumper;
  warn Dumper(\@pending_joins);
  
  
  my @pending_invites = $c->model('ROMEDB::WorkgroupInvite')->search(person=>$c->user->username);
  $c->stash->{pending_invites} = \@pending_invites if scalar(@pending_invites);
  
  $c->stash->{template}="workgroup/admin.tt2";
}





=head2 autocomplete_leader

  Returns a list of usernames for autocompleting leader

=cut

sub autocomplete_leader : Local {

  my ($self, $c) = @_;
  my $val ='%';
  $val = $val.$c->request->params->{leader}.'%' if  $c->request->params->{leader};
  my %complete_list =  map {$_->username => $self->make_name($_)}
    $c->model('ROMEDB::Person')->search_like({username=>$val});
  
  $c->stash->{ajax} = "1";
  $c->stash->{template}='scriptaculous/autocomplete_list.tt2';
  $c->stash->{complete_list}= \%complete_list;
}

=head2 make_name
  
  Utility method. 
  Returns a "forname surname" string when given a person DB object

=cut

sub make_name{
  my $self = shift;
  my $person = shift;
  my $name ='';
  $name.= $person->forename.' ' if $person->forename;
  $name .= $person->surname if $person->surname;
  return $name;
}


=head2 _validate_add_params

  Private action. DFV check for all fields in workgroup

=cut

 sub _validate_add_params :Private {
   my ($self, $c) = @_;
   my $dfv_profile = 
     {
      required => [qw(name leader)],
      optional => [qw(description)],
      msgs => {
	       format => '%s',
	       constraints => 
	       {
		'user_exists' => 'User not found.',
		'allowed_chars' => 'Please use only letters and numbers in this field.',
		'allowed_chars_plus' => 'Please use only letters, numbers, spaces and basic punctuation (,.-_) in this field.',
		'workgroup_exists' => 'A workgroup with that name already exists.',
		'is_current_user_or_admin' => 'You may only create workgroups with yourself as leader.',
	       },
	      },
      filters => ['trim'],
      missing_optional_valid => 1,    
      constraint_methods => 
      {
       leader => [ROME::Constraints::user_exists($c),
		  ROME::Constraints::is_current_user_or_admin($c)],
       name => [ROME::Constraints::allowed_chars,
	        ROME::Constraints::not_workgroup_exists($c)],
       description => ROME::Constraints::allowed_chars_plus,
      },
     };
   $c->form($dfv_profile);
 }



=head2 add
  
   /workgroup/add

   This is an AJAX method

   The result will contain a status_msg or an error_msg.


=head3  Parameters:

=over 2

=item  name 

   The name of the new role. 

=item description 

   An optional description for the new role

=item leader

   Optional -  will default to your own username
  
   If you have admin rights, you can specify a username other than your own.

=back


=cut

sub add : Local {
  my($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  #set current user as default for leader:
  $c->request->params->{leader} = $c->request->params->{leader} || $c->user->username;
 
  # check params, create workgroup
  my $workgroup;
  if ($c->forward('_validate_add_params')){
    #create the wg
    $workgroup = $c->model('ROMEDB::Workgroup')->create
      ({
	name        => $c->request->params->{name},
	description => $c->request->params->{description},
	leader      => $c->request->params->{leader},
       });
    
    #and add the leader as a member. 
    my $person_wg = $c->model('ROMEDB::PersonWorkgroup')->create
      ({
	person => $c->request->params->{leader},
	workgroup => $c->request->params->{name},
       });
  }
  else{
    $c->stash->{invalid_params} = $c->form->msgs; #store dfv error msgs for xmlrpc calls
    $c->stash->{error_msg} = 'Invalid Params'; 
    return;
  }
  
  # success?
  if ($workgroup = $c->model('ROMEDB::Workgroup')->find($c->request->params->{name})) {
    $c->stash->{status_msg} = 'Workgroup '.$workgroup->name.' was created';
  }
  else{
    # set status to 500 - Server Error 
     $c->response->{status} = '500';
     $c->stash->{error_msg} = 'Server Error';
   }
  
}


=head2 list_user_workgroups

  An AJAX action which returns the current user's workgroups list.

=cut

sub list_user_workgroups : Local{
  my ($self,$c) = @_;

  my @workgroups = $c->user->workgroups;
  my @workgroups_led = $c->user->workgroups_led;

  $c->stash->{ajax} = 1;
  $c->stash->{workgroups_member} = \@workgroups;
  $c->stash->{workgroups_led}= \@workgroups_led;
  $c->stash->{template}="workgroup/my_workgroups.tt2";

}


=head2 _validate_delete_params

  Private action. DFV check for rolename param

=cut

sub _validate_delete_params :Private {
  my ($self, $c) = @_;
  my $dfv_profile = 
    {
     required => [qw(name)],
     msgs => 
     {
      format => '%s',
      constraints => 
      {
       workgroup_exists => 'Workgroup not found.',
       user_can_update_workgroup => 'You cannot delete this workgroup.'
      },
     },
     filters => ['trim'],
     constraint_methods => 
     {
      name => [ROME::Constraints::workgroup_exists($c),
	       ROME::Constraints::user_can_update_workgroup($c),]
     },
    };

  $c->form($dfv_profile);
}


=head2 delete

   Delete a workgroup

   /workgroup/delete?name=workgroupname

=cut


sub delete : Local {
  my($self, $c, $name) = @_;


  $c->request->params->{name} = $name if $name;
  $c->stash->{template} = 'messages.tt2';
  $c->stash->{ajax} = 1;
  
  #check params, delete role
  my $workgroup;
  if ($c->forward('_validate_delete_params')){
    $workgroup =  $c->model("ROMEDB::Workgroup")->find($c->request->params->{name});
    $workgroup->delete;
  }
   else{
     $c->stash->{error_msg} = 'Invalid Params'; 
     return;
   }
  
   # success?
  unless ($workgroup = $c->model('ROMEDB::Workgroup')->find($c->request->params->{name})) {
    $c->stash->{status_msg} = 'Workgroup '.$c->request->params->{name}.' was deleted';
  }
  else{
    # set status to 500 - Server Error 
     $c->response->{status} = '500';
     $c->stash->{error_msg} = 'Server Error';
   }
  
}



=head search

   /workgroup/search
   Will return a list of Workgroups matching the pattern in the database
  
   You can use * as wildcard.

=cut

sub search : Local {

    my($self, $c) = @_;
    
    $c->stash->{template} = 'workgroup/list.tt2' if $c->request->headers->header('x-requested-with');
    $c->stash->{ajax} = 1;
    
    my @workgroups;
    my $pattern = $c->request->params->{pattern};
    if ($pattern){
	$pattern =~ s/![\w\s]//g;
	$pattern =~s /\*/\%/g;
	
	@workgroups = $c->model('ROMEDB::Workgroup')->search_like({name => $pattern});
    }
    else{
	@workgroups = $c->model('ROMEDB::Workgroup')->all;
    }
    
    #stick them in the stash
    if (scalar(@workgroups)){
	$c->stash->{workgroups} = \@workgroups;
	return;
    } 
    else {
	$c->stash->{error_msg}="No workgroups found";
	return;
    }
    
}

=head2 update_form

   An AJAX method to send back an update form for a given workgroup

=cut

sub update_form : Local{
  my ($self,$c) = @_;

  $c->stash->{ajax} = 1;

  if ($c->forward('_validate_update_form_params')){
    my $workgroupname = $c->request->params->{workgroup};
    my $workgroup = $c->model('ROMEDB::Workgroup')->find($workgroupname);
    $c->stash->{workgroup} = $workgroup;
    $c->stash->{template} = 'workgroup/update_form.tt2';
  }
  else{
    $c->stash->{template} = 'messages.tt2';
  }
  
  return;
}


#private action for validating the update_form params
sub _validate_update_form_params :Private{
  my ($self,$c) = @_;
  my $dfv_profile = 
    {
     required => ['workgroup'],
     msgs =>
     {
      format => '%s',
      constraints =>
      {
       workgroup_exists => 'Workgroup not found',
       user_can_update_workgroup => 'You do not have permission to update that group.',
      },
     },
     filters => ['trim'],
     constraint_methods => 
     {
      workgroup => [ROME::Constraints::workgroup_exists($c),
	      ROME::Constraints::user_can_update_workgroup($c)],
     }
    };
      
  $c->form($dfv_profile);

}


 # Private action. DFV check for all fields in workgroup.
 sub _validate_update_params :Private {
   my ($self, $c) = @_;
   my $dfv_profile = 
     {
      required => [qw(name)],
      optional => [qw(description leader)],
      msgs => 
      {
       format => '%s',
       constraints => 
       {
	allowed_chars_plus => 'Please use only letters, numbers, spaces and basic punctuation (,.-_) in this field',
	workgroup_exists => 'Workgroup not found.',
	user_can_update_workgroup => 'You do not have permission to update this workgroup.',
	user_exists => 'User not found',
	user_in_workgroup => 'New leader must be a member of the group.',
       },
      },
      filters => ['trim'],
      missing_optional_valid => 1,    
      constraint_methods => 
      {
       name => [ROME::Constraints::workgroup_exists($c),
		ROME::Constraints::user_can_update_workgroup($c)],
       description => ROME::Constraints::allowed_chars_plus,
       leader => [ROME::Constraints::user_exists($c),
		  ROME::Constraints::user_in_workgroup('name', $c)],
      },
     };

   $c->form($dfv_profile);
 }


=head2 update

   AJAX method to update the workgroup

=cut

sub update : Local {
   my($self, $c) = @_;

   $c->stash->{template} = 'messages.tt2';
   $c->stash->{ajax} = 1;

   # check params, update role
   my $workgroup;
   if ($c->forward('_validate_update_params')){

     #find the workgroup
     $workgroup = $c->model('ROMEDB::Workgroup')->find($c->request->params->{name}); 

     unless ($workgroup){
	 $c->stash->{error_msg} = "Workgroup not found";
	 return;
     }
    
     #update the workgroup
     $workgroup->description($c->request->params->{description});
     $workgroup->leader($c->request->params->{leader});
     $workgroup->update;
   }
   else{
     $c->stash->{invalid_params} = $c->form->msgs; #store dfv error msgs for xmlrpc calls
     $c->stash->{error_msg} = 'Invalid Params'; 
     return;
   }
  
   # success?
   $c->stash->{status_msg} = 'Workgroup '.$workgroup->name.' was updated';

 }



sub _validate_manage_params : Private{
    
    my ($self,$c) = @_;
    
    my $dfv_profile = 
    {
	required => [qw(workgroup)],
	msgs => 
	{
	    format => '%s',
            constraints => 
            {
	      allowed_chars => 'Please use only letters and numbers in this field.',
	      workgroup_exists => 'Workgroup not found.',
	      user_can_update_workgroup => 'You do not have permissions to manage that workgroup',
            },
        },
      filters => ['trim'],
      constraint_methods => 
      {
       workgroup => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::workgroup_exists($c),
                     ROME::Constraints::user_can_update_workgroup($c),
		     ],
      },
     };

   $c->form($dfv_profile);    


}


=head2 manage

This returns the workgroup management page.

=cut

sub manage : Local{
    my ($self,$c, $workgroup) = @_;

    $c->request->params->{workgroup} = $workgroup if $workgroup;

    if ($c->forward('_validate_manage_params')  ){
	
	my $wg = $c->model('ROMEDB::Workgroup')->find($c->request->params->{workgroup});
	unless ($wg){
	    $c->stash->{error_msg} = 'workgroup not found';
	}
	$c->stash->{workgroup} = $wg; 

	my @pending_joins = $c->model('ROMEDB::WorkgroupJoinRequest')->search(workgroup=>$wg->name);
	$c->stash->{pending_joins} = \@pending_joins if scalar(@pending_joins);

	
	my @pending_invites = $c->model('ROMEDB::WorkgroupInvite')->search(workgroup=>$wg->name);
	$c->stash->{pending_invites} = \@pending_invites if scalar(@pending_invites);

	
    }

    $c->stash->{template} = 'workgroup/manage.tt2';
    return;

}




sub _validate_pending_join_params :Private{
    my ($self,$c) = @_;
    
    my $dfv_profile = 
    {
	required => [qw(workgroup)],
	msgs => 
	{
	    format => '%s',
            constraints => 
            {
	      allowed_chars => 'Please use only letters and numbers in this field.',
	      workgroup_exists => 'Workgroup not found.',
	      user_can_update_workgroup => 'You do not have permissions to manage that workgroup',
            },
        },
      filters => ['trim'],
      constraint_methods => 
      {
       workgroup => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::workgroup_exists($c),
                     ROME::Constraints::user_can_update_workgroup($c),
		     ],
      },
     };

   $c->form($dfv_profile);    

}

=head2 pending_joins
 
 An ajax method which will return the most recent pending joins for 
 a given workgroup as a list.

 Requires group ownership or admin.

=cut

sub pending_joins : Local{
    my ($self,$c, $workgroup) = @_;
    $c->stash->{ajax} = 1;
    $c->request->params->{workgroup} = $workgroup if $workgroup;    
    if ($c->forward('_validate_pending_join_params')){
	my @pending_joins = $c->model('ROMEDB::WorkgroupJoinRequest')->search(workgroup=>$workgroup);
	$c->stash->{template} = 'workgroup/pending_join_list.tt2';
	$c->stash->{pending_joins} = \@pending_joins;
    }
    return;
}


=head2 autocomplete

   Returns a list of names for autocompleting workgroup fields

=cut

sub autocomplete : Local {
  my ($self, $c) = @_;
  my $val = $c->request->params->{workgroup};
  $c->stash->{ajax} = 1;
  my %complete_list =  map {$_->name=>$_->description} 
    $c->model('ROMEDB::Workgroup')->search_like({name=>'%'.$val.'%'});
  
  $c->stash->{template}='scriptaculous/autocomplete_list.tt2';
  $c->stash->{complete_list}=\%complete_list;
}


# private action, checks join params
sub _validate_join_params : Private{
  my ($self, $c) = @_;
  my $dfv_profile = 
    {
     required => [qw(workgroup)],
     msgs => 
      {
       format => '%s',
       constraints => 
       {
	allowed_chars => 'Please use only letters and numbers in this field.',
	workgroup_exists => 'Workgroup not found.',
	not_current_user_in_workgroup => 'User already a member of workgroup.',
        not_workgroup_join_pending => 'You already have a request awaiting approval by the leader of that group',
       },
      },
      filters => ['trim'],
      constraint_methods => 
      {
       workgroup => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::workgroup_exists($c),
		     ROME::Constraints::not_current_user_in_workgroup($c),
                     ROME::Constraints::not_workgroup_join_pending($c),
		     ],
      },
     };

   $c->form($dfv_profile);
}


=head2 join 

  An ajax method to add a member to this group

  Note that this only creates the ROMEDB::WorkgroupJoinRequest.
  Membership will only be created when the group owner (or an admin)
  calls confirm_join

=cut
sub join :Local {
   my ($self, $c, $workgroup) = @_;
  
   $c->request->params->{workgroup} = $workgroup if $workgroup;
   $c->stash->{ajax} = 1;
   $c->stash->{template} = 'messages.tt2';

   if ($c->forward('_validate_join_params')  ){

     #create the request
       my $wg  = $c->model('ROMEDB::Workgroup')->find($c->request->params->{workgroup});
 
       my $jr = $c->model('ROMEDB::WorkgroupJoinRequest')->create({person=>$c->user->username,
								   workgroup=>$wg->name});
       
       #email the group leader
       my $confirm_link = $c->uri_for('workgroup/confirm_join')
	   .'/'
	   .$jr->workgroup->name
	   .'/'
	   .$jr->person->username;
       
       my $deny_link = $c->uri_for('workgroup/deny_join')
	   .'/'
	   .$jr->workgroup->name
	   .'/'
	   .$jr->person->username;
       
       
       #build the message
       my $msg = MIME::Lite::TT::HTML->new(
	   From => 'no-reply',
	   To => $wg->leader->email,
	   Subject => 'ROME: join request for workgroup '.$jr->workgroup->name,
	   Template => {text =>'workgroup_join_request.tt',
			html => 'workgroup_join_request.html.tt'
	   },
	   TmplParams => {jr => $jr,
			  confirm_link => $confirm_link,
			  deny_link => $deny_link,
			  admin_email => $c->config->{admin_email},
	   }, 
	   TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	   
	   );
       

       $msg->send();
       
       if ($jr){
	   $c->stash->{status_msg} = 'Your request to join workgroup '.$wg->name.' has been sent. You will be emailed when the group leader processes the request.'
       }
       else{
	   $c->stash->{error_msg}= "Request not sent. Please contact the system administrator ".$c->config->{admin_email};
       }
   }
   
}

=head2 confirm_join

  An ajax method to allow the owner of a group, 
  or an administrator, to confirm a pending join request

=cut

sub confirm_join:Local{
  
    my ($self,$c, $wg, $person) = @_;
     
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'messages.tt2';

    #stick url params in form params for validation.
    $c->request->params->{workgroup}= $wg if $wg;
    $c->request->params->{person} = $person if $person;

    if ($c->forward('_validate_confirm_join_params')){
	#delete the pending request.
	my $pend = $c->model('ROMEDB::WorkgroupJoinRequest')->find({
	    person => $c->request->params->{person},
	    workgroup => $c->request->params->{workgroup},
								   });
	unless ($pend){
	    $c->stash->{error_msg} = "Pending Request not found. Please contact administrator";
	    return;
	}
	
	$pend->delete;

	#add the user to the group
	my $memb = $c->model('ROMEDB::PersonWorkgroup')->create({
	    person => $c->request->params->{person},
	    workgroup => $c->request->params->{workgroup}
							});
	
	$c->stash->{status_msg} = "Membership confirmed for user ".$c->request->params->{person};

	# email user.
	my $user = $c->model('ROMEDB::Person')->find({username=>$c->request->params->{person}});
	my $workgroup = $c->model('ROMEDB:Workgroup')->find({name=>$c->request->params->{workgroup}});
	my $msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $user->email,
	    Subject => 'ROME Workgroup Membership',
		Template => {text =>'workgroup_membership.tt',
			     html => 'workgroup_membership.html.tt'
	    },
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
	    }, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();
	
	# email workgroup owner
	$msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $workgroup->leader->email,
	    Subject => 'ROME Workgroup Membership',
	    Template => {text =>'workgroup_membership.tt',
			 html => 'workgroup_membership.html.tt'
	},
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
	}, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();
    }
    
    return;

}

#private 

sub _validate_confirm_join_params : Private{
  my ($self, $c) = @_;
  my $dfv_profile = 
    {
     required => [qw(workgroup person)],
     msgs => 
      {
       format => '%s',
       constraints => 
       {
	allowed_chars => 'Please use only letters and numbers in this field',
	workgroup_exists => 'Workgroup not found.',
	user_exists => 'User not found',
	user_can_update_workgroup => 'Only the group leader, or an administrator can confirm a request to join a group.',
       },
      },
      filters => ['trim'],
      constraint_methods => 
      {
       workgroup => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::workgroup_exists($c),
		     ROME::Constraints::user_can_update_workgroup($c),
		    ],
       person    => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::user_exists($c),
		    ],
      },
     };

   $c->form($dfv_profile);
}


=head2 deny_join

  An ajax method to allow the owner of a group,
  or an administrator, to deny a pending join request

=cut

sub deny_join :Local{
  
    my ($self,$c, $wg, $person) = @_;
    
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'messages.tt2';
    
    $c->request->params->{workgroup}= $wg if $wg;
    $c->request->params->{person} = $person if $person;
    
    if ($c->forward('_validate_confirm_join_params')){
	#delete the pending request.
	my $pend = $c->model('ROMEDB::WorkgroupJoinRequest')->find({
	    person => $c->request->params->{person},
	    workgroup => $c->request->params->{workgroup},
								   });
	unless ($pend){
	    $c->stash->{error_msg} = "Pending Request not found. Please contact administrator";
	    return;
	}
	
	$pend->delete;

	$c->stash->{status_msg} = "Membership denied for user ".$c->request->params->{person};
	
	# email user.
	my $user = $c->model('ROMEDB::Person')->find({username=>$c->request->params->{person}});
	my $workgroup = $c->model('ROMEDB:Workgroup')->find({name=>$c->request->params->{workgroup}});
	my $msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $user->email,
	    Subject => 'ROME Workgroup Membership',
	    Template => {text =>'workgroup_deny_membership.tt',
			 html => 'workgroup_deny_membership.html.tt'
	    },
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
	    }, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();
	
	# email workgroup owner
	$msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $workgroup->leader->email,
	    Subject => 'ROME Workgroup Membership',
	    Template => {text =>'workgroup_deny_membership.tt',
			 html => 'workgroup_deny_membership.html.tt'
	},
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
	    }, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();


    }
    
    return;
}







sub _validate_invite_params :Private {
    my ($self,$c) = @_;

     my $dfv_profile = 
    {
	required => [qw(workgroup person)],
	msgs => 
	{
	    format => '%s',
       constraints => 
       {
	allowed_chars => 'Please use only letters and numbers in this field',
	workgroup_exists => 'Workgroup not found.',
	user_exists => 'User not found',
	user_can_update_workgroup => 'Only the group leader, or an administrator can invite people to join a group.',
        not_user_in_workgroup => 'User is already a workgroup member',
        not_workgroup_invite_pending => 'User has already been invited to join group and is yet to respond',
       },
      },
      filters => ['trim'],
      constraint_methods => 
      {
       workgroup => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::workgroup_exists($c),
		     ROME::Constraints::user_can_update_workgroup($c),
		    ],
       person    => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::user_exists($c),
                     ROME::Constraints::not_user_in_workgroup('workgroup',$c),
                     ROME::Constraints::not_workgroup_invite_pending($c,'workgroup'),
		    ],
      },
     };

   $c->form($dfv_profile);    
}

=head2 invite

  An ajax method to allow the owner of a group, 
  or an administrator, to invite people to join
  a group

=cut

sub invite :Local{
    my ($self,$c) = @_;
    
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'messages.tt2';

    if ($c->forward('_validate_invite_params')){

	#create the workgroup_invite entry
	my $w_i = $c->model('ROMEDB::WorkgroupInvite')->create({
	    person => $c->request->params->{person},
	    workgroup => $c->request->params->{workgroup},	
							       });
	unless ($w_i){
	    $c->stash->{error_msg} = "Failed to send invite, please contact administrator";
	    return;
	}
	
	#email the user
	my $user = $c->model('ROMEDB::Person')->find($c->request->params->{person});
	my $workgroup = $c->model('ROMEDB::Workgroup')->find($c->request->params->{workgroup});
	my $accept_link =  $c->uri_for('/workgroup/confirm_invite/'.$c->request->params->{workgroup}.'/'.$c->request->params->{person});
	my $deny_link = $c->uri_for('/workgroup/deny_invite/'.$c->request->params->{workgroup}.'/'.$c->request->params->{person});
	
	
	my $msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $user->email,
	    Subject => 'ROME Workgroup Invitation',
		Template => {text =>'workgroup_invite.tt',
			     html => 'workgroup_invite.html.tt'
	    },
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
			   accept_link  => $accept_link,
			   deny_link     => $deny_link,
	    }, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();
	
	$c->stash->{status_msg} = 'An invitation has been sent to user '.$c->request->params->{person};
	
    }
}

=head2 confirm_invite

  An ajax method to allow a user to confirm
  an invitation to a group

=cut

sub confirm_invite: Local{
   
    my ($self,$c, $wg, $person) = @_;
     
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'messages.tt2';

    #stick url params in form params for validation.
    $c->request->params->{workgroup}= $wg if $wg;
    $c->request->params->{person} = $person if $person;

    if ($c->forward('_validate_confirm_invite_params')){
	#delete the pending request.
	my $pend = $c->model('ROMEDB::WorkgroupInvite')->find({
	    person => $c->request->params->{person},
	    workgroup => $c->request->params->{workgroup},
								   });
	unless ($pend){
	    $c->stash->{error_msg} = "Pending Request not found. Please contact administrator";
	    return;
	}
	
	$pend->delete;

	#add the user to the group
	my $memb = $c->model('ROMEDB::PersonWorkgroup')->create({
	    person => $c->request->params->{person},
	    workgroup => $c->request->params->{workgroup}
							});
	
	$c->stash->{status_msg} = "Membership confirmed for user ".$c->request->params->{person};

	# email user.
	my $user = $c->model('ROMEDB::Person')->find({username=>$c->request->params->{person}});
	my $workgroup = $c->model('ROMEDB::Workgroup')->find({name=>$c->request->params->{workgroup}});
	my $msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $user->email,
	    Subject => 'ROME Workgroup Membership',
		Template => {text =>'workgroup_membership.tt',
			     html => 'workgroup_membership.html.tt'
	    },
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
	    }, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();
	
	# email workgroup owner
	$msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $workgroup->leader->email,
	    Subject => 'ROME Workgroup Membership',
	    Template => {text =>'workgroup_membership.tt',
			 html => 'workgroup_membership.html.tt'
	},
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
	}, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();
    }
    
    return;


}



# private : DFV check params for confirm_invite
sub _validate_confirm_invite_params : Private{
  my ($self, $c) = @_;
  my $dfv_profile = 
    {
     required => [qw(workgroup person)],
     msgs => 
      {
       format => '%s',
       constraints => 
       {
	allowed_chars => 'Please use only letters and numbers in this field',
	workgroup_exists => 'Workgroup not found.',
	user_exists => 'User not found',
	user_is_invited => 'You have not been invited to join this group',
       },
      },
      filters => ['trim'],
      constraint_methods => 
      {
       workgroup => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::workgroup_exists($c),
		     ROME::Constraints::user_is_invited($c),
		    ],
       person    => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::user_exists($c),
		    ],
      },
     };

   $c->form($dfv_profile);
}



=head2 deny_invite

  An ajax method to allow a user to decline
  an invitation to join a group

=cut

sub deny_invite:Local{
 
    my ($self,$c, $wg, $person) = @_;
    
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'messages.tt2';
    
    $c->request->params->{workgroup}= $wg if $wg;
    $c->request->params->{person} = $person if $person;
    
    if ($c->forward('_validate_confirm_invite_params')){
	#delete the pending request.
	my $pend = $c->model('ROMEDB::WorkgroupInvite')->find({
	    person => $c->request->params->{person},
	    workgroup => $c->request->params->{workgroup},
								   });
	unless ($pend){
	    $c->stash->{error_msg} = "Pending Request not found. Please contact administrator";
	    return;
	}
	
	$pend->delete;

	$c->stash->{status_msg} = "Membership denied for user ".$c->request->params->{person};
	
	# email user.
	my $user = $c->model('ROMEDB::Person')->find({username=>$c->request->params->{person}});
	my $workgroup = $c->model('ROMEDB::Workgroup')->find({name=>$c->request->params->{workgroup}});
	my $msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $user->email,
	    Subject => 'ROME Workgroup Membership',
	    Template => {text =>'workgroup_deny_membership.tt',
			 html => 'workgroup_deny_membership.html.tt'
	    },
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
	    }, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();
	
	# email workgroup owner
	$msg = MIME::Lite::TT::HTML->new(
	    From => 'no-reply',
	    To => $workgroup->leader->email,
	    Subject => 'ROME Workgroup Membership',
	    Template => {text =>'workgroup_deny_membership.tt',
			 html => 'workgroup_deny_membership.html.tt'
	},
	    TmplParams => {user          => $user,
			   workgroup     => $workgroup,
	    }, 
	    TmplOptions => {INCLUDE_PATH => $c->path_to( 'root' ).'/email_templates'},
	    );
	
	$msg->send();


    }
    
    return;
}





=head2 pending_invites
 
 An ajax method which will return the pending invites for the current user.

=cut

sub pending_invites : Local{
    my ($self,$c) = @_;
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'workgroup/pending_invites_user.tt2';
    my @pending_invites = $c->model('ROMEDB::WorkgroupInvite')->search(person=>$c->user->username);
    $c->stash->{pending_invites} =\@pending_invites if scalar(@pending_invites);

    warn "in pending_invites";
    return;
}






 # Private action.
 sub _validate_leave_params :Private {
   my ($self, $c) = @_;
   my $dfv_profile = 
     {
      required => [qw(workgroup)],
      msgs => 
      {
       format => '%s',
       constraints => 
       {
	allowed_chars => 'Please use only letters and numbers in this field.',
	workgroup_exists => 'Workgroup not found.',
	not_user_owns_workgroup => 'Group leader cannot leave group. You may delete the whole group or give leadership to someone else.'
       },
      },
      filters => ['trim'],
      constraint_methods => 
      {
       workgroup => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::workgroup_exists($c),
		     ROME::Constraints::not_user_owns_workgroup($c),
		     ],
      },
     };

   $c->form($dfv_profile);
 }


=head2 leave

   AJAX method to allow the current user to leave
   the workgroup

   Also see 'remove' which allows the group leader
   or admin to remove a member from the group.

=cut


sub leave : Local {
   my($self, $c) = @_;

   $c->stash->{template} = 'messages.tt2';
   $c->stash->{ajax} = 1;

   # check params, update role
   my $workgroup;
   if ($c->forward('_validate_leave_params')){

     #find the workgroup
     my $person_wg = $c->model('ROMEDB::PersonWorkgroup')->find(
							     $c->user->username,
							     $c->request->params->{workgroup}); 
    
     $person_wg->delete;
   }
   else{
     $c->stash->{invalid_params} = $c->form->msgs; #store dfv error msgs for xmlrpc calls
     return;
   }
  
   # success?
   $c->stash->{status_msg} = $c->user->username.' has left workgroup '.$c->request->params->{workgroup};

 }



sub _validate_remove_params : Private{
    my ($self,$c) = @_;
    my $dfv_profile = 
    {
	required => [qw(workgroup person)],
	msgs => 
	{
	    format => '%s',
       constraints => 
       {
	allowed_chars => 'Please use only letters and numbers in this field',
	workgroup_exists => 'Workgroup not found.',
	user_exists => 'User not found',
	user_can_update_workgroup => 'Only the group leader, or an administrator can remove a group member.',
        not_this_user_owns_workgroup=>'Group leader cannot be removed',
       },
      },
      filters => ['trim'],
      constraint_methods => 
      {
       workgroup => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::workgroup_exists($c),
		     ROME::Constraints::user_can_update_workgroup($c),
		    ],
       person    => [
		     ROME::Constraints::allowed_chars,
		     ROME::Constraints::user_exists($c),
                     ROME::Constraints::not_this_user_owns_workgroup($c,'workgroup')
		    ],
      },
     };

   $c->form($dfv_profile);   
}
 
=head2 remove

  Ajax action allowing the owner (or admin) to remove workgroup members

=cut

sub remove : Local {
   my($self, $c, $workgroup,$person) = @_;
   
   $c->stash->{template} = 'messages.tt2';
   $c->stash->{ajax} = 1;
   
   $c->request->params->{workgroup} = $workgroup if $workgroup;
   $c->request->params->{person} = $person if $person;

   # check params, update role
   if ($c->forward('_validate_remove_params')){
       
       #find the membership
       my $person_wg = $c->model('ROMEDB::PersonWorkgroup')->find({
	   person => $c->request->params->{person},
	   workgroup => $c->request->params->{workgroup}
								  });
       #and delete it
       $person_wg->delete;
       $c->stash->{status_msg} = "User ".$c->request->params->{person}. "has been removed from group ".$c->request->params->{workgroup};
       
       #and email the user to let them know.
       ### TO DO ###
	   
   }

}







=head2 members_autocomplete
  
   Returns a list of members, formatted for the autocompleter.

=cut

sub members_autocomplete :Local{
    my ($self, $c, $workgroup) = @_;
    
    $c->request->params->{workgroup} = $workgroup if $workgroup;
    my $val = $c->request->params->{person};  
    $val =~s/[^\w\d]//g;

    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'scriptaculous/autocomplete_list.tt2';

    #check that the workgroup exists amd that the user is a member. 
    #If not, just return nothing - can't really put an error message
    #into an autocomplete list
    my $wg = $c->request->params->{workgroup};
    return unless $wg =~/^[\d\w]+$/;
    
    my $is_member = $c->model('ROMEDB::PersonWorkgroup')->find($c->user->username, $wg);
    $wg = $c->model('ROMEDB::Workgroup')->find($c->request->params->{workgroup});
    
    # check access permissions
    return unless (
	$c->check_user_roles('admin') 
	|| $is_member);
    
    
    my %complete_list = map {$_->username=>' '.$_->forename.' '.$_->surname} 
    grep {$_->username =~/.*$val.*/} 
    $wg->people;
    $c->stash->{complete_list} = \%complete_list;
}





=head2 users_autocomplete

  Returns a list of usernames for autocompleting person fields

=cut

sub users_autocomplete : Local {
  my ($self, $c) = @_;
  my $val = $c->request->params->{person2};
  my %complete_list =  map {$_->username=>$_->forename.' '.$_->surname} 
                         $c->model('ROMEDB::Person')->search_like({username=>'%'.$val.'%'});
  
  $c->stash->{ajax} = "1";
  $c->stash->{template}='scriptaculous/autocomplete_list.tt2';
  $c->stash->{complete_list}=\%complete_list;
}





=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
