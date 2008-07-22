package ROME::Controller::Experiment;

use strict;
use warnings;
use base 'ROME::Controller::Base';
use ROME::Constraints;
use Date::Calc;
use Path::Class;

=head1 NAME

ROME::Controller::Experiment - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

   matches /experiment
   
   Returns an admin GUI 

=cut

sub index : Private{
  my ($self, $c) = @_;

  #return an admin GUI page with AJAX calls to your various methods.
  $c->stash->{template} = 'experiment/admin'; 
}


# Private action. DFV check for the add action
sub _validate_add_params :Private {
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(name owner)],
		     optional => [qw(description pubmed_id )],
		     msgs => {
			      format => '%s',
			      constraints => {
                                  'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
				  'allowed_chars' => 'Please use only letters and numbers in this field',
                                  'valid_pubmed' => 'The PMID should only contain numbers',
				  'user_exists' => 'Not a valid username',
				  'experiment_exists' => 'You already have an experiment with that name',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
                                            description => ROME::Constraints::allowed_chars_plus,
                                            pubmed_id   => ROME::Constraints::valid_pubmed,
                                            owner => ROME::Constraints::user_exists($c),
					    name => [
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::not_experiment_exists($c,'owner'),
						    ],

					   },
		    };
 
 $c->form($dfv_profile);

}



=head2 add
  
  /experiment/add

  Add a new experiment

  Note -  this method sets the date_created field to the current date
  it also sets the status of the experiment to private.

=head3  Parameters:

=over 2

=item  name 

  The name of the new experiment.Must be unique for this user.

=item owner

  The username of the owner of the new experiment. 

  Unless the user has admin rights, this must be the current user (and defaults to such).

=item description

  An optional description of the new experiment. 
  This should just be a brief description 
  details of the treatments applied are stored elsewhere.

=item pubmed_id

  An optional pubmed id of the paper describing this experiment.

=back

=cut

sub add : Local{
  my($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax}=1;

  #default to current user as owner
  $c->request->params->{owner} = $c->user->username unless $c->request->params->{owner};

  # check access permissions
  unless ($c->check_user_roles('admin')){
    if ($c->request->params->{owner} ne $c->user->username){
      $c->stash->{error_msg} = "You don't have permission to create experiments for other users";
      return;
    }
  } 

  # check params
  my $experiment;
  my $date = Date::Calc::Today;
  if ($c->forward('_validate_add_params')){

    $experiment = $c->model('ROMEDB::Experiment')->create({
							   name         => $c->request->params->{name},
							   owner        => $c->request->params->{owner},
							   pubmed_id    => $c->request->params->{pubmed_id},
							   description  => $c->request->params->{description},
							   date_created => join("-",Date::Calc::Today()),
							   status       => 'private',
							  });

# don't - just name datafiles with the job id as a suffix and they're guaranteed unique.
#    #and create a directory in which to store the files belonging to this expeirment
#    my $dir = dir($c->config->{userdata},$c->user->username,$experiment->name);
#    unless($dir->mkpath){
#	$c->stash->{error_msg} = "Failed to create directory for this experiment. Contact your system administator";
#	$c->debug("Failed to make experiment dir $dir");
#	return;
#    } 
    
    $c->stash->{status_msg} = "Experiment ".$experiment->name." was created for user ".$experiment->owner->username;
    return;
  }
  else{
    $c->stash->{invalid_params} = $c->form->msgs; #store dfv error msgs for xmlrpc calls
    return;
  }
  
}



# Private action. DFV check for rolename param
sub _validate_delete_params :Private {
  my ($self, $c) = @_;

  my $dfv_profile = {
		     required => [qw(name owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
				 'user_exists' => 
				       "Invalid username. Please check.",
                                  'experiment_exists'=> 
					      "That experiment is not found in the database",
					     },
			     },
		     filters => ['trim'],
		     constraint_methods => {
					    owner => ROME::Constraints::user_exists($c),
					    name  => ROME::Constraints::experiment_exists($c,'owner')
					   },

		    };
  $c->form($dfv_profile);

}



=head2 delete

  Delete an experiment

  Requires Admin or ownership of experiment.

  /experiment/delete?name=experimentname&owner=username

=cut

sub delete : Local {

  my($self, $c, $name, $owner) = @_;

  $c->request->params->{name} = $name if $name;
  $c->request->params->{owner} = $owner if $owner;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  #check params
  my $experiment;
  if ($c->forward('_validate_delete_params')){
    
    $experiment = $c->model('ROMEDB::Experiment')->find($c->request->params->{name}, 
						       $c->request->params->{owner});

    # check access permissions
    unless ($c->check_user_roles('admin') || $c->user->username eq $experiment->owner->username){
      $c->stash->{error_msg} = 'Access Denied. You do not have permission to delete this experiment.';
      return;
    } 

    #check current users
    if(my @users = $experiment->current_users){
      $c->stash->{error_msg} = 'Deletion forbidden. Experiment in use by other people.';
      return;
    }

    #delete the experiment.
    $experiment->delete;
    $c->stash->{status_msg} = 'Experiment '.$c->request->params->{name}.' was deleted';
  }
  else{
    $c->response->status('500');
    $c->stash->{invalid_params} = $c->form->msgs; #store dfv error msgs for xmlrpc calls
    $c->stash->{error_msg} = 'Invalid Params'; 
    return;
  }

  
}




=head2 search_like

  /experiment/search_like

  Will return a list of Experiments matching the pattern in the database

  Only experiments visible to the current user are listed.
  
  You can use * as wildcard.

  parameters are pattern (the pattern to search with) and which ('all' or 'mine')

  Returns an unordered list of experiments with set-as-active, delete and update links 
  depending on the user's access rights.

=cut


sub search_like :Local{

  my($self, $c) = @_;
  $c->stash->{template} = 'experiment/list';
  $c->stash->{ajax}=1;

  #grab the post params so we can reload the list if we need to
  $c->stash->{which} = $c->request->params->{which};
  $c->stash->{pattern} = $c->request->params->{pattern};


  my (@my_experiments, @shared_experiments, @public_experiments);
  my $pattern = $c->request->params->{pattern} || '%';
  $pattern =~ s/![\w\s]//g;
  $pattern =~s /\*/\%/g;
  
  my $which = $c->request->params->{which} || 'mine';

  #Grab the user's experiments, matching the pattern
  @my_experiments = $c->model('ROMEDB::Experiment')->search_like({name => $pattern,
							       owner=> $c->user->username,
							      });
 
  unless($which eq 'mine') {
    
    #grab all the public experiments which match the pattern
    @public_experiments = $c->model('ROMEDB::Experiment')->search_like({name=>$pattern,
									status=>'public',
								       });

    #grab all the shared experiments this user has access to which match the pattern
    @shared_experiments = $c->model('ROMEDB::Experiment')->search_like
      (
       {'person.username' => $c->user->username,
	status => 'shared',
	'me.name' => $pattern,
       },
       {join=>{
	       map_experiment_workgroups=>
	       {workgroup=>
		{map_person_workgroup => 'person'}
	       }
	      }
       },
      );

    

  }

  $c->stash->{my_experiments} = \@my_experiments;
  $c->stash->{shared_experiments} = \@shared_experiments;
  $c->stash->{public_experiments} = \@public_experiments;
  return;
}




sub _validate_update_form_params :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(name owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
				 'experiment_exists' => 
				       "Experiment not found",
                                  'user_exists'=> 
					      "User not found",
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

=head2 update_form

  An AJAX method to send back an update form for a given experiment

=cut

sub update_form : Local{
  my ($self,$c, $name, $owner) = @_;
 
  $c->request->params->{name} = $name if $name;
  $c->request->params->{owner} = $owner if $owner;

  $c->stash->{template} = 'experiment/update_form';
  $c->stash->{ajax}=1;

  #default to current user as owner
  $c->request->params->{owner} = $c->user->username unless $c->request->params->{owner};

  # check access permissions
  unless ($c->check_user_roles('admin')){
    if ($c->request->params->{owner} ne $c->user->username){
      $c->stash->{error_msg} = "You don't have permission to update experiments for other users";
      return;
    }
  } 
 
  if ($c->forward('_validate_update_form_params')){
    my $experiment = $c->model('ROMEDB::Experiment')->find($c->request->params->{name}, $c->request->params->{owner});
    $c->stash->{experiment} = $experiment;
  }
}




# Private action. DFV check for all fields in role.
sub _validate_update_params :Private {

  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(name owner)],
		     optional => [qw(description pubmed_id )],
		     msgs => {
			      format => '%s',
			      constraints => {
				  'allowed_chars_plus' => 
     				     "Please use only letters, numbers, spaces and simple punctuation (,.-_) in this field",
                                  'valid_pubmed' => 'The PMID should only contain numbers',
				  'experiment_exists'   => 
				      'experiment not found',
                                  'user_exists' => 'user not found',
				  'valid_experiment_status' => 'Not a valid status',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
                                            description => ROME::Constraints::allowed_chars_plus,
                                            pubmed_id   => ROME::Constraints::valid_pubmed,
                                            owner       => ROME::Constraints::user_exists($c),
					    name        => ROME::Constraints::experiment_exists($c, 'owner'), 
					    status      => ROME::Constraints::valid_experiment_status,
					   },
		    };
 
 $c->form($dfv_profile);
}


=head2 update

  ajax method to update this experiment

=cut

sub update : Local{
  my($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax}=1;

  #default to current user as owner
  $c->request->params->{owner} = $c->user->username unless $c->request->params->{owner};

  # check access permissions
  unless ($c->check_user_roles('admin')){
    if ($c->request->params->{owner} ne $c->user->username){
      $c->stash->{error_msg} = "You don't have permission to update experiments for other users";
      return;
    }
  } 

  # check params 
  my $experiment;
  if ($c->forward('_validate_update_params')){

    #find the experiment
    $experiment = $c->model('ROMEDB::Experiment')->find($c->request->params->{name}, $c->request->params->{owner}); 
    
    #update the experiment
    $experiment->description($c->request->params->{description});
    $experiment->pubmed_id($c->request->params->{pubmed_id});
    $experiment->status($c->request->params->{status});
    $experiment->update;

    $c->stash->{status_msg} = 'Experiment '.$experiment->name.' was updated';
  }
  else{
    $c->stash->{invalid_params} = $c->form->msgs; #store dfv error msgs for xmlrpc calls
    return;
  }
  
}



=head2 autocomplete

  Returns a list of names for autocompleting experiment fields.

  Each also has span of class "informal" containing the description
  which is used for display purposes but not set in the value

=cut 

sub autocomplete : Local {

  my ($self, $c) = @_;
  my $val = $c->request->params->{experiment_name};
  $val =~ s/\*/%/g;
  $c->stash->{ajax} = 1;
  
  my $experiments; 
  if ($c->check_user_roles('admin')){
    $experiments = $c->model('ROMEDB::Experiment')->search_like({name=>'%'.$val.'%'});
  }
  else{
    $experiments = $c->model('ROMEDB::ExperimentByUser')->search_like({name=>'%'.$val.'%'},  {bind=>[$c->user->username, $c->user->username]});
  }

  $c->stash->{template} = 'experiment/autocomplete';
  $c->stash->{experiments} = $experiments;

}



=head2 autocomplete_owner

  Returns a list of usernames for autocompleting owner

=cut

sub autocomplete_owner : Local {

  my ($self, $c) = @_;
  my $val = $c->request->params->{owner};
  my %complete_list =  map {$_->username=>$_->forename.' '.$_->surname} 
                         $c->model('ROMEDB::Person')->search_like({username=>'%'.$val.'%'});
  
  $c->stash->{ajax} = "1";
  $c->stash->{template}='scriptaculous/autocomplete_list';
  $c->stash->{complete_list}=\%complete_list;
}


sub _validate_share_with_all : Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(experiment_name experiment_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      experiment_exists => 'Experiment not found',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    experiment_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    experiment_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::experiment_exists($c,'experiment_owner'),
							   ],
					    },
		    };
  $c->form($dfv_profile);  
}


=item share_with_all

  Share the given experiment with all users

  ajax: /experiment/share_with_all
  parameters are experiment_name, experiment_owner.

  If no parameters are supplied the current experiment is used.

=cut
sub share_with_all :Local{
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

   #default to currently selected experiment
    unless ($c->request->params->{experiment_name}){
      $c->request->params->{experiment_name} =  $c->user->experiment->name;
      $c->request->params->{experiment_owner} = $c->user->experiment->owner->username;
    }
    # check params, 
    if ($c->forward('_validate_share_with_all')){

    # check access permissions
    unless ($c->check_user_roles('admin')){
	unless ($c->request->params->{'experiment_owner'} eq $c->user->username){
	    $c->stash->{error_msg} = "Access Denied. You may not share other people's experiments.";
	    return;
	}
    }

    #retrieve the experiment
    my $experiment = $c->model('ROMEDB::Experiment')->find(
	    $c->request->params->{'experiment_name'},
	    $c->request->params->{'experiment_owner'}
	);

    unless ($experiment){
      $c->{error_msg} = 'Experiment not found';
      return;
    }
    $experiment->status('public');
    $experiment->update;

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Experiment shared with all users';   
}










sub _validate_share_with_workgroup : Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(experiment_owner experiment_name workgroup_name)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      factor_exists => 'Factor not found',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					      experiment_not_in_workgroup => 'Experiment is already shared with workgroup',
					      experiment_not_public => "This experiment is already public",
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    experiment_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    experiment_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::experiment_exists($c,'experiment_owner'),
							    ROME::Constraints::experiment_not_in_workgroup($c, 'experiment_owner','workgroup_name'),
							    ROME::Constraints::experiment_not_public($c,'experiment_owner')
							   ],
					    workgroup_name => [
							       ROME::Constraints::is_single,
							       ROME::Constraints::allowed_chars,
							      ]
					    },
		    };
  $c->form($dfv_profile);  
}


=item experiment_share_with_workgroup

  Share the given experiment with the given workgroup

  ajax: /metadata/experiment/share_with_workgroup
  parameters are experiment_name, experiment_owner, workgroup_name

  Defaults to using the selected experiment.

=cut
sub share_with_workgroup :Local{
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

    #default to currently selected experiment
    unless ($c->request->params->{experiment_name}){
      $c->request->params->{experiment_name} =  $c->user->experiment->name;
      $c->request->params->{experiment_owner} = $c->user->experiment->owner->username;
    }

    # check params, 
    if ($c->forward('_validate_share_with_workgroup')){

    # check access permissions
    unless ($c->check_user_roles('admin')){
	unless ($c->request->params->{'experiment_owner'} eq $c->user->username){
	    $c->stash->{error_msg} = "Access Denied. You may not share other people's experiments.";
	    return;
	}
    }

    #retrieve the factor
    my $experiment = $c->model('ROMEDB::Experiment')->find(
	    $c->request->params->{'experiment_name'},
	    $c->request->params->{'experiment_owner'}
	);

    unless ($experiment){
      $c->{error_msg} = 'Experiment not found';
      return;
    }
    $experiment->status('shared');
    $experiment->update;

    #create the link
    my $expt_wg = $c->model('ROMEDB::ExperimentWorkgroup')->create
      (
       {
	experiment_name  => $experiment->name,
	experiment_owner => $experiment->owner->username,
	workgroup   => $c->request->params->{'workgroup_name'}
       }
      );

    unless ($expt_wg){
      $c->stash->{error_msg} = 'Failed to add experiment to workgroup';
      return;
    }

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Experiment shared with workgroup';   
}



=item current

  ajax: experiment current

  Hands the experiment/current template off to the view

=cut
sub current :Local{
  my ($self,$c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'experiment/current'
}



#### Listing and updating experimental outcomes.



=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
