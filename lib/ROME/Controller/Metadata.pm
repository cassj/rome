package ROME::Controller::Metadata;

use strict;
use warnings;
use base 'ROME::Controller::Base';
use ROME::Constraints;

=head1 NAME

ROME::Controller::Metadata - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=over 2

=cut


=item index 

  Matches metadata/ and sends the admin template to the view

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'metadata/admin';
}



=item owner_autocomplete

  ajax : /metadata/owner_autocomplete

  autocomplete support for owner fields.

=cut

sub owner_autocomplete :Local {
  my ($self, $c) = @_;

  my $val = $c->request->params->{factor_owner};
  $val=~s/\*/%/;
  $c->stash->{ajax} = 1;

  my $people =$c->model('ROMEDB::Person')->search_like({username=>'%'.$val.'%'});

  $c->stash->{template} = 'metadata/owner_autocomplete';
  $c->stash->{people} = $people;


}



sub _validate_factor_add_params :Private {
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(factor_name factor_owner)],
		     optional => [qw(factor_description)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      not_factor_exists => 'A factor of that name already exists',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::user_exists($c),
							    ],
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::not_factor_exists($c,'factor_owner'),
							   ],
					    factor_description => [
								   ROME::Constraints::is_single,
								   ROME::Constraints::allowed_chars_plus,
								  ]
					    },
		    };
  $c->form($dfv_profile);
}



=item factor_add

  /metadata/factor/add

  factor_name:
    The name of the new factor 
    Must be unique for the owner

  factor_owner:
    The owner of the factor. 
    Defaults to the current user.
    Only the administrator can create factors for other users.

  factor_description:
    An optional description for the factor

=cut

sub factor_add : Path('factor/add') {
  my($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  #default to current user as owner.
  $c->request->params->{factor_owner} = $c->user->username unless $c->request->params->{factor_owner};

  # check select experiment access permissions
  unless ($c->check_user_roles('admin')){
    unless ($c->user->experiment->owner->username == $c->user->username){
      $c->stash->{error_msg} = "Access Denied. You may not add factors to other people's exeperiments.";
      return;
    }
    unless ($c->user->username == $c->request->params->{factor_owner}){
      $c->stash->{error_msg} = 'Access Denied. You do not have permission to add factors for other users.';
      return;
    }
  }
  
  # check params, create 
  my $factor;
  if ($c->forward('_validate_factor_add_params')){
    $factor = $c->model('ROMEDB::Factor')->create
      ({
	name        => $c->request->params->{factor_name},
	owner       => $c->request->params->{factor_owner},
	description => $c->request->params->{factor_description},
	status      => 'private',
       });

    unless ($factor){
      $c->stash->{error_msg} = "Failed to insert factor into the database";
      return;
    }
    
    #link to expt
    my $fac_expt = $c->model('ROMEDB::FactorExperiment')->create
      ({
	factor_name => $factor->name,
	factor_owner => $factor->owner->username,
	experiment_name => $c->user->experiment->name,
	experiment_owner => $c->user->experiment->owner->username,
       });
    
    unless ($fac_expt){
      $c->stash->{error_msg} = "Failed to link factor to experiment";
      return;
    }
  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Factor '.$factor->name.' was created';
 
}





sub _validate_factor_add_to_experiment :Private {
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(factor_name factor_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      factor_exists => 'Factor does not exist',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::user_exists($c),
							    ],
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::factor_exists($c,'factor_owner'),
							   ],
					    factor_description => [
								   ROME::Constraints::is_single,
								   ROME::Constraints::allowed_chars_plus,
								  ]
					    },
		    };
  $c->form($dfv_profile);
}



=item factor_add_to_experiment

   Adds the selected factor to the current experiment

  /metadata/factor/add_to_experiment

  factor_name:
    The name of the new factor 
    Must be unique for the owner

  factor_owner:
    The owner of the factor. 
    Defaults to the current user.

=cut

sub factor_add_to_experiment : Path('factor/add_to_experiment') {
  my($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  #default to current user as owner.
  $c->request->params->{factor_owner} = $c->user->username unless $c->request->params->{factor_owner};

  # check params, add to experiment
  my $factor;
  if ($c->forward('_validate_factor_add_to_experiment')){

    #retrieve the requested factor

    $factor = $c->model('ROMEDB::Factor')->find
      (
       $c->request->params->{factor_name},
       $c->request->params->{factor_owner},
       );

    #check access permissions
    unless ($c->check_user_roles('admin')){
      unless ($factor->status eq 'public'){
	unless ($c->user->username eq $factor->owner->username){
	  my $visible = 0;
	  if ($factor->status eq 'shared'){
	    #user_workgroups
	    my %user_wgs = map {$_->name => 1} $c->user->workgroups;
	    while (my $fac_wg = $factor->workgroups->next){
	      if (defined $user_wgs{$fac_wg->name}){
		#ok, it's visible
		$visible = 1;
		$factor->workgroups->reset;
		last;
	      }
	    }
	  }
	  unless ($visible){
	    $c->stash->{error_msg} = "You don't have access to that factor";
	    return;
	  }
	}
      }
    }

    
    #link to expt
    my $fac_expt = $c->model('ROMEDB::FactorExperiment')->create
      ({
	factor_name => $factor->name,
	factor_owner => $factor->owner->username,
	experiment_name => $c->user->experiment->name,
	experiment_owner => $c->user->experiment->owner->username,
       });
    
    unless ($fac_expt){
      $c->stash->{error_msg} = "Failed to link factor to experiment";
      return;
    }
  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Factor '.$factor->name.' was added to experiment';
 
}








sub _validate_level_add_params :Private {
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(factor_name factor_owner level_name)],
		     optional => [qw(level_description)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      factor_exists => 'Factor not found',
					      not_level_exists => 'Factor already has that level',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::user_exists($c),
							    ],
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::factor_exists($c,'factor_owner'),
							   ],
					    level_name => [
							   ROME::Constraints::is_single,
							   ROME::Constraints::allowed_chars,
							   ROME::Constraints::not_level_exists($c, 'factor_name', 'factor_wowner')
							  ],
					    level_description => [
								  ROME::Constraints::is_single,
								  ROME::Constraints::allowed_chars_plus,
								 ]
					    },
		    };
  $c->form($dfv_profile);
}



=item level_add

  /metadata/level/add

  level_name
     The name of the level to create

  factor_name, factor_owner
     The primary key fields of the factor to which we are adding a level

  level_description:
    An optional description for the level

=cut

sub level_add : Path('level/add') {
  my($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  #default to current user as factor_owner.
  $c->request->params->{factor_owner} = $c->user->username unless $c->request->params->{factor_owner};

  # check select experiment access permissions
  unless ($c->check_user_roles('admin')){
    unless ($c->user->username == $c->request->params->{factor_owner}){
      $c->stash->{error_msg} = "Access Denied. You do not have permission to add levels to other users' factors.";
      return;
    }
  }
  
  # check params, create 
  my $level;
  if ($c->forward('_validate_level_add_params')){
    $level = $c->model('ROMEDB::Level')->create
      ({
	name          => $c->request->params->{level_name},
	factor_name   => $c->request->params->{factor_name},
	factor_owner  => $c->request->params->{factor_owner},
	description   => $c->request->params->{level_description},
       });

    unless ($level){
      $c->stash->{error_msg} = "Failed to insert level into the database";
      return;
    }
  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Level '.$level->name.' was created';
 
}



=item factor_create_form

  Ajax: /metadata/factor/create_form

  Hands the factor create form template to the view.



=cut

sub factor_create_form :Path('factor/create_form'){
  my ($self, $c) = @_;
  $c->stash->{template} = 'metadata/factor_create_form';
  $c->stash->{ajax} = 1;
}




=item level_create_form

  Ajax: /metadata/level/create_form

  Hands the level create form template to the view.



=cut

sub level_create_form :Path('level/create_form'){
  my ($self, $c) = @_;
  $c->stash->{template} = 'metadata/level_create_form';
  $c->stash->{ajax} = 1;
}



=item factor_autocomplete

  ajax : /metadata/factor/autocomplete

  autocomplete support for factor_name fields.

=cut

sub factor_autocomplete :Path('factor/autocomplete') {
  my ($self, $c) = @_;

  my $val = $c->request->params->{factor_name};
  $val=~s/\*/%/;
  $c->stash->{ajax} = 1;

  
  my $factors; 
  if ($c->check_user_roles('admin')){
    $factors = $c->model('ROMEDB::Factor')->search_like({name=>'%'.$val.'%'});
  }
  else{
    $factors = $c->model('ROMEDB::FactorByUser')->search_like({name=>'%'.$val.'%'},  {bind=>[$c->user->username, $c->user->username]});
  }


  $c->stash->{template} = 'metadata/factor_autocomplete';
  $c->stash->{factors} = $factors;
}


=item factor_list

  ajax: /metadata/factor/list

  Passes the factor_list template to the view.

=cut

sub factor_list :Path('factor/list'){
  my ($self,$c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'metadata/factor_list';
}



sub _validate_delete_factor_params :Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(factor_name factor_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      not_factor_exists => 'A factor of that name already exists',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
				    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::factor_exists($c,'factor_owner'),
							   ],
					    },
		    };
  $c->form($dfv_profile);  
}


=item delete_factor

  ajax: /metadata/factor/delete
  parameters are factor_name and factor_owner.

=cut
sub delete_factor :Path('factor/delete'){
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

    #default to current user as owner.
    $c->request->params->{factor_owner} = $c->user->username unless $c->request->params->{factor_owner};

    # check params, create 
    if ($c->forward('_validate_delete_factor_params')){

    # check access permissions
    unless ($c->check_user_roles('admin')){
	unless ($c->request->params->{'factor_owner'} == $c->user->username){
	    $c->stash->{error_msg} = "Access Denied. You may not delete other people's factors.";
	    return;
	}
    }

    my $factor = $c->model('ROMEDB::Factor')->find(
						   $c->request->param('factor_name'),
						   $c->request->param('factor_owner')
						  );

    $factor->delete;

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Factor deleted';   
}





sub _validate_delete_factor_from_experiment : Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(factor_name factor_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      factor_exists => 'A factor of that name already exists',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
                                              factor_in_experiment => 'Factor is not in this experiment',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::factor_exists($c,'factor_owner'),
                                                            ROME::Constraints::factor_in_experiment($c,'factor_owner', $c->user->experiment)
							   ],
					    },
		    };
  $c->form($dfv_profile);  
}


=item delete_factor_from_experiment

  Deletes the given factor from the current experiment

  ajax: /metadata/factor/delete_from_experiment
  parameters are factor_name, factor_owner.
  

=cut
sub delete_factor_from_experiment :Path('factor/delete_from_experiment'){
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;
    
    #default to current user as owner.
    $c->request->params->{factor_owner} = $c->user->username unless $c->request->params->{factor_owner};

    # check params, create 
    if ($c->forward('_validate_delete_factor_from_experiment')){

    #retrieve the factorexperiment and delete it
    my $factor_expt = $c->model('ROMEDB::FactorExperiment')->find(
	    $c->request->param('factor_name'),
	    $c->request->param('factor_owner'),
	    $c->user->experiment->name,
	    $c->user->experiment->owner->username,
	);

    $factor_expt->delete;

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Factor deleted from experiment';   
}




sub _validate_factor_share_all : Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(factor_name factor_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      factor_exists => 'Factor not found',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::factor_exists($c,'factor_owner'),
							   ],
					    },
		    };
  $c->form($dfv_profile);  
}


=item factor_share_all

  Share the given factor with all users

  ajax: /metadata/factor/share_with_all
  parameters are factor_name, factor_owner.
  

=cut
sub factor_share_all :Path('factor/share_with_all'){
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;
    
    #default to current user as owner.
    $c->request->params->{factor_owner} = $c->user->username unless $c->request->params->{factor_owner};

    # check params, 
    if ($c->forward('_validate_factor_share_all')){

    # check access permissions
    unless ($c->check_user_roles('admin')){
	unless ($c->request->params->{'factor_owner'} == $c->user->username){
	    $c->stash->{error_msg} = "Access Denied. You may not share other people's factors.";
	    return;
	}
    }

    #retrieve the factor
    my $factor = $c->model('ROMEDB::Factor')->find(
	    $c->request->param('factor_name'),
	    $c->request->param('factor_owner')
	);

    unless ($factor){
      $c->{error_msg} = 'Factor not found';
      return;
    }
    $factor->status('public');
    $factor->update;

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Factor shared with all users';   
}










sub _validate_factor_share_workgroup : Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(factor_name factor_owner workgroup_name)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      factor_exists => 'Factor not found',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					      factor_not_in_workgroup => 'Factor is already shared with workgroup',
					      factor_not_public => "This factor is already public",
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::factor_exists($c,'factor_owner'),
							    ROME::Constraints::factor_not_in_workgroup($c, 'factor_owner','workgroup_name'),
							    ROME::Constraints::factor_not_public($c,'factor_owner')
							   ],
					    workgroup_name => [
							       ROME::Constraints::is_single,
							       ROME::Constraints::allowed_chars,
							      ]
					    },
		    };
  $c->form($dfv_profile);  
}


=item factor_share_workgroup

  Share the given factor with the given workgroup

  ajax: /metadata/factor/share_with_workgroup
  parameters are factor_name, factor_owner, workgroup_name
  

=cut
sub factor_share_workgroup :Path('factor/share_with_workgroup'){
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;
    
    #default to current user as owner.
    $c->request->params->{factor_owner} = $c->user->username unless $c->request->params->{factor_owner};

    # check params, 
    if ($c->forward('_validate_factor_share_workgroup')){

    # check access permissions
    unless ($c->check_user_roles('admin')){
	unless ($c->request->params->{'factor_owner'} eq $c->user->username){
	    $c->stash->{error_msg} = "Access Denied. You may not share other people's factors.";
	    return;
	}
    }

    #retrieve the factor
    my $factor = $c->model('ROMEDB::Factor')->find(
	    $c->request->param('factor_name'),
	    $c->request->param('factor_owner')
	);

    unless ($factor){
      $c->{error_msg} = 'Factor not found';
      return;
    }
    $factor->status('shared');
    $factor->update;

    #create the link
    my $fac_wg = $c->model('ROMEDB::FactorWorkgroup')->create
      (
       {
	factor_name    => $factor->name,
	factor_owner   => $factor->owner->username,
	workgroup_name => $c->request->params->{'workgroup_name'}
       }
      );

    unless ($fac_wg){
      $c->stash->{error_msg} = 'Failed to add factor to workgroup';
      return;
    }

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Factor shared with workgroup';   
}










###########################################

sub _validate_cont_var_add_params :Private {
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(cont_var_name cont_var_owner)],
		     optional => [qw(cont_var_description)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      not_cont_var_exists => 'A vraiable of that name already exists',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    cont_var_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::user_exists($c),
							    ],
					    cont_var_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::not_cont_var_exists($c,'cont_var_owner'),
							   ],
					    cont_var_description => [
								   ROME::Constraints::is_single,
								   ROME::Constraints::allowed_chars_plus,
								  ]
					    },
		    };
  $c->form($dfv_profile);
}



=item cont_var_add

  /metadata/cont_var/add

  cont_var_name:
    The name of the new continuous variable 
    Must be unique for the owner

  cont_var_owner:
    The owner of the variable. 
    Defaults to the current user.
    Only the administrator can create variables for other users.

  cont_var_description:
    An optional description for the variable

=cut

sub cont_var_add : Path('cont_var/add') {
  my($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  #default to current user as owner.
  $c->request->params->{cont_var_owner} = $c->user->username unless $c->request->params->{cont_var_owner};

  # check select experiment access permissions
  unless ($c->check_user_roles('admin')){
    unless ($c->user->experiment->owner->username == $c->user->username){
      $c->stash->{error_msg} = "Access Denied. You may not add variables to other people's exeperiments.";
      return;
    }
    unless ($c->user->username == $c->request->params->{cont_var_owner}){
      $c->stash->{error_msg} = 'Access Denied. You do not have permission to add variables for other users.';
      return;
    }
  }
  
  # check params, create 
  my $cont_var;
  if ($c->forward('_validate_cont_var_add_params')){
    $cont_var = $c->model('ROMEDB::ContVar')->create
      ({
	name        => $c->request->params->{cont_var_name},
	owner       => $c->request->params->{cont_var_owner},
	description => $c->request->params->{cont_var_description},
	status      => 'private',
       });

    unless ($cont_var){
      $c->stash->{error_msg} = "Failed to insert variable into the database";
      return;
    }
    
    #link to expt
    my $cv_expt = $c->model('ROMEDB::ContVarExperiment')->create
      ({
	cont_var_name => $cont_var->name,
	cont_var_owner => $cont_var->owner->username,
	experiment_name => $c->user->experiment->name,
	experiment_owner => $c->user->experiment->owner->username,
       });
    
    unless ($cv_expt){
      $c->stash->{error_msg} = "Failed to link variable to experiment";
      return;
    }
  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Variable '.$cont_var->name.' was created';
 
}





sub _validate_cont_var_add_to_experiment :Private {
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(cont_var_name cont_var_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      cont_var_exists => 'Variable does not exist',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					      cont_var_not_in_experiment => 'Variable is already in this experiment',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    cont_var_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::user_exists($c),
							    ],
					    cont_var_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::cont_var_exists($c,'cont_var_owner'),
                                                            ROME::Constraints::cont_var_not_in_experiment($c,'cont_var_owner', $c->user->experiment)

							   ],
					    cont_var_description => [
								   ROME::Constraints::is_single,
								   ROME::Constraints::allowed_chars_plus,
								  ]
					    },
		    };
  $c->form($dfv_profile);
}



=item cont_var_add_to_experiment

   Adds the selected continuous variable to the current experiment

  /metadata/cont_var/add_to_experiment

  cont_var_name:
    The name of the new variable 
    Must be unique for the owner

  cont_var_owner:
    The owner of the variable. 
    Defaults to the current user.

=cut

sub cont_var_add_to_experiment : Path('cont_var/add_to_experiment') {
  my($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  #default to current user as owner.
  $c->request->params->{cont_var_owner} = $c->user->username unless $c->request->params->{cont_var_owner};

  # check params, add to experiment
  my $cont_var;
  if ($c->forward('_validate_cont_var_add_to_experiment')){

    #retrieve the requested variable

    $cont_var = $c->model('ROMEDB::ContVar')->find
      (
       $c->request->params->{cont_var_name},
       $c->request->params->{cont_var_owner},
       );

    #check access permissions
    unless ($c->check_user_roles('admin')){
      unless ($cont_var->status eq 'public'){
	unless ($c->user->username eq $cont_var->owner->username){
	  my $visible = 0;
	  if ($cont_var->status eq 'shared'){
	    #user_workgroups
	    my %user_wgs = map {$_->name => 1} $c->user->workgroups;
	    while (my $cv_wg = $cont_var->workgroups->next){
	      if (defined $user_wgs{$cv_wg->name}){
		#ok, it's visible
		$visible = 1;
		$cont_var->workgroups->reset;
		last;
	      }
	    }
	  }
	  unless ($visible){
	    $c->stash->{error_msg} = "You don't have access to that variable";
	    return;
	  }
	}
      }
    }

    
    #link to expt
    my $cv_expt = $c->model('ROMEDB::ContVarExperiment')->create
      ({
	cont_var_name => $cont_var->name,
	cont_var_owner => $cont_var->owner->username,
	experiment_name => $c->user->experiment->name,
	experiment_owner => $c->user->experiment->owner->username,
       });
    
    unless ($cv_expt){
      $c->stash->{error_msg} = "Failed to link variable to experiment";
      return;
    }
  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Variable '.$cont_var->name.' was added to experiment';
 
}




=item cont_var_create_form

  Ajax: /metadata/cont_var/create_form

  Hands the continuous variable create form template to the view.



=cut

sub cont_var_create_form :Path('cont_var/create_form'){
  my ($self, $c) = @_;
  $c->stash->{template} = 'metadata/cont_var_create_form';
  $c->stash->{ajax} = 1;
}



=item cont_var_autocomplete

  ajax : /metadata/cont_var/autocomplete

  autocomplete support for cont_var_name fields.

=cut

sub cont_var_autocomplete :Path('cont_var/autocomplete') {
  my ($self, $c) = @_;

  my $val = $c->request->params->{cont_var_name};
  $val=~s/\*/%/;
  $c->stash->{ajax} = 1;

  
  my $cont_vars; 
  if ($c->check_user_roles('admin')){
    $cont_vars = $c->model('ROMEDB::ContVar')->search_like({name=>'%'.$val.'%'});
  }
  else{
    $cont_vars = $c->model('ROMEDB::ContVarByUser')->search_like({name=>'%'.$val.'%'},  {bind=>[$c->user->username, $c->user->username]});    
  }

  $c->stash->{template} = 'metadata/cont_var_autocomplete';
  $c->stash->{cont_vars} = $cont_vars;
}


=item cont_var_list

  ajax: /metadata/cont_var/list

  Passes the cont_var_list template to the view.

=cut

sub cont_var_list :Path('cont_var/list'){
  my ($self,$c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'metadata/cont_var_list';
}



sub _validate_delete_cont_var_params :Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(cont_var_name cont_var_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      cont_var_exists => 'A variable of that name already exists',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    cont_var_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    cont_var_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::cont_var_exists($c,'cont_var_owner'),
							   ],
					    },
		    };
  $c->form($dfv_profile);  
}


=item delete_cont_var

  ajax: /metadata/cont_var/delete
  parameters are cont_var_name and cont_var_owner.

=cut
sub cont_var_delete :Path('cont_var/delete'){
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

    #default to current user as owner.
    $c->request->params->{cont_var_owner} = $c->user->username unless $c->request->params->{cont_var_owner};

    # check params, create 
    if ($c->forward('_validate_delete_cont_var_params')){

    # check access permissions
    unless ($c->check_user_roles('admin')){
	unless ($c->request->params->{'cont_var_owner'} == $c->user->username){
	    $c->stash->{error_msg} = "Access Denied. You may not delete other people's variables.";
	    return;
	}
    }

    my $cont_var = $c->model('ROMEDB::ContVar')->find(
						   $c->request->param('cont_var_name'),
						   $c->request->param('cont_var_owner')
						  );

    $cont_var->delete;

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Variable deleted';   
}





sub _validate_delete_cont_var_from_experiment : Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(cont_var_name cont_var_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      not_cont_var_exists => 'A variable of that name already exists',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
                                              cont_var_in_experiment => 'Variable is not in this experiment',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    cont_var_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    cont_var_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::cont_var_exists($c,'cont_var_owner'),
                                                            ROME::Constraints::cont_var_in_experiment($c,'cont_var_owner', $c->user->experiment)
							   ],
					    },
		    };
  $c->form($dfv_profile);  
}


=item delete_cont_var_from_experiment

  Deletes the given variable from the current experiment

  ajax: /metadata/cont_var/delete_from_experiment
  parameters are cont_var_name, cont_var_owner.
  

=cut
sub delete_cont_var_from_experiment :Path('cont_var/delete_from_experiment'){
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;
    
    #default to current user as owner.
    $c->request->params->{cont_var_owner} = $c->user->username unless $c->request->params->{cont_var_owner};

    # check params, create 
    if ($c->forward('_validate_delete_cont_var_from_experiment')){

    #retrieve the cont_var_experiment and delete it
    my $cont_var_expt = $c->model('ROMEDB::ContVarExperiment')->find(
	    $c->request->param('cont_var_name'),
	    $c->request->param('cont_var_owner'),
	    $c->user->experiment->name,
	    $c->user->experiment->owner->username,
	);

    $cont_var_expt->delete;

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Variable deleted from experiment';   
}





sub _validate_cont_var_share_all : Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(cont_var_name cont_var_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      cont_var_exists => 'A factor of that name already exists',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    cont_var_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    cont_var_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::cont_var_exists($c,'cont_var_owner'),
							   ],
					    },
		    };
  $c->form($dfv_profile);  
}


=item cont_var_share_all

  Share the given variable with all users

  ajax: /metadata/cont_var/share_with_all
  parameters are cont_var_name, cont_var_owner.
  

=cut
sub cont_var_share_all :Path('cont_var/share_with_all'){
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;
    
    #default to current user as owner.
    $c->request->params->{cont_var_owner} = $c->user->username unless $c->request->params->{cont_var_owner};

    # check params, 
    if ($c->forward('_validate_cont_var_share_all')){

    # check access permissions
    unless ($c->check_user_roles('admin')){
	unless ($c->request->params->{'cont_var_owner'} == $c->user->username){
	    $c->stash->{error_msg} = "Access Denied. You may not share other people's variables.";
	    return;
	}
    }

    #retrieve the variable
    my $cont_var = $c->model('ROMEDB::ContVar')->find(
	    $c->request->param('cont_var_name'),
	    $c->request->param('cont_var_owner')
	);

    unless ($cont_var){
      $c->{error_msg} = 'Variable not found';
      return;
    }
    $cont_var->status('public');
    $cont_var->update;

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Variable shared with all users';   
}



sub _validate_cont_var_share_workgroup : Local{
    my ($self, $c) = @_;
    my $dfv_profile = {
		     required => [qw(cont_var_name cont_var_owner workgroup_name)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single => "Can't have multiple values",
					      allowed_chars => 'Please use only letters and numbers in this field',
					      user_exists => 'User not found',
					      cont_var_exists => 'Variable not found',
					      allowed_chars_plus => 'Please use only letters, numbers, commas, full stops and spaces in this field',
					      cont_var_not_in_workgroup => 'Variable is already shared with workgroup',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    cont_var_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    cont_var_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::cont_var_exists($c,'cont_var_owner'),
							    ROME::Constraints::cont_var_not_in_workgroup($c, 'cont_var_owner','workgroup_name')
							   ],
					    workgroup_name => [
							       ROME::Constraints::is_single,
							       ROME::Constraints::allowed_chars,
							      ]
					    },
		    };
  $c->form($dfv_profile);  
}


=item cont_var_share_workgroup

  Share the given continuous variable with the given workgroup

  ajax: /metadata/cont_var/share_with_workgroup
  parameters are cont_var_name, cont_var_owner, workgroup_name
  

=cut
sub cont_var_share_workgroup :Path('cont_var/share_with_workgroup'){
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;
    
    #default to current user as owner.
    $c->request->params->{cont_var_owner} = $c->user->username unless $c->request->params->{cont_var_owner};

    # check params, 
    if ($c->forward('_validate_cont_var_share_workgroup')){

    # check access permissions
    unless ($c->check_user_roles('admin')){
	unless ($c->request->params->{'cont_var_owner'} eq $c->user->username){
	    $c->stash->{error_msg} = "Access Denied. You may not share other people's variables.";
	    return;
	}
    }

    #retrieve the variable
    my $cont_var = $c->model('ROMEDB::ContVar')->find(
	    $c->request->param('cont_var_name'),
	    $c->request->param('cont_var_owner')
	);

    unless ($cont_var){
      $c->{error_msg} = 'Variable not found';
      return;
    }
    $cont_var->status('shared');
    $cont_var->update;

    #create the link
    my $cv_wg = $c->model('ROMEDB::ContVarWorkgroup')->create
      (
       {
	cont_var_name    => $cont_var->name,
	cont_var_owner   => $cont_var->owner->username,
	workgroup_name => $c->request->params->{'workgroup_name'}
       }
      );

    unless ($cv_wg){
      $c->stash->{error_msg} = 'Failed to add variable to workgroup';
      return
    }

  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }
  
  # success?
  $c->stash->{status_msg} = 'Variable shared with workgroup';   
}



### Assigning factor levels and variable values to experimental outcomes

=item outcome_list

  metadata/outcome/list

  hands the outcomes template to the view

=cut
sub outcome_list :Path('outcome/list'){
    my ($self, $c) = @_;
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'metadata/outcomes';
}



sub _validate_outcome_add_level :Local{
   my ($self, $c) = @_;

    my $dfv_profile = {
		     required => [qw(factor_name factor_owner level_name outcome_name experiment_name experiment_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single=> "Can't have multiple values",
					      allowed_chars => "Should only contain letters numbers or '_'",
					      factor_exists => "Factor not found",
					      outcome_exists => "Outcome not found",
					      not_outcome_has_factor => "Outcome already has a level defined for that factor",
					      experiment_has_factor => "Factor is not in this experiment",
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::factor_exists($c,'factor_owner'),
							   ],
					    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    level_name => [
							   ROME::Constraints::is_single,
							   ROME::Constraints::allowed_chars,
							  ],
					    outcome_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::outcome_exists($c,'experiment_name','experiment_owner'),
							     ROME::Constraints::not_outcome_has_factor($c,'experiment_name','experiment_owner','factor_name', 'factor_owner' ),
							    ],
					    experiment_name => [
								ROME::Constraints::is_single,
								ROME::Constraints::allowed_chars,
								ROME::Constraints::experiment_exists($c,'experiment_owner'),
								ROME::Constraints::experiment_has_factor($c, 'experiment_owner', 'factor_name', 'factor_owner'),
							       ],
					    experiment_owner => [
								 ROME::Constraints::is_single,
								 ROME::Constraints::allowed_chars,
								],

					    },
		    };
  $c->form($dfv_profile);  
}

=item outcome_add_level

   metadata/outcome/add_level

   params are:
   factor_name
   factor_owner 
   level_name
   outcome_name
   experiment_name  (experiment defaults to that currently selected.
   experiment_owner

    Note that the outcome name needs to be the actual name, not the display name.

=cut
sub outcome_add_level :Path('outcome/add_level'){
    my ($self, $c) = @_;
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'site/messages';

    unless ($c->request->params->{experiment_name}){
	$c->request->params->{experiment_name} = $c->user->experiment->name;
	$c->request->params->{experiment_owner} = $c->user->experiment->owner->username;
    }

    my $out;
    if ($c->forward('_validate_outcome_add_level')){
	
	
	#add the level to the outcome
	my $out_lev = $c->model('ROMEDB::OutcomeLevel')->create
	    ({
		outcome_name => $c->request->params->{outcome_name},
		outcome_experiment_name => $c->request->params->{experiment_name},
		outcome_experiment_owner => $c->request->params->{experiment_owner},
		level_factor_name => $c->request->params->{factor_name},
		level_factor_owner => $c->request->params->{factor_owner},
		level_name => $c->request->params->{level_name},
	     });
	
	unless ($out_lev){
	    $c->stash->{error_msg} = 'Failed to add level to outcome';
	return;
	}
	
	$out = $c->model('ROMEDB::Outcome')->find(
	    $c->request->params->{outcome_name},
	    $c->request->params->{experiment_name},
	    $c->request->params->{experiment_owner}
	    );
	
    }
    else{
	$c->stash->{error_msg} = 'Invalid Parameters'; 
	return;
    }

    $c->stash->{status_msg} = 'Added '.$c->request->params->{factor_name}.'-'.$c->request->params->{level_name}.' to '.$out->display_name;
    
}






sub _validate_outcome_delete_level :Local{
   my ($self, $c) = @_;

    my $dfv_profile = {
		     required => [qw(factor_name factor_owner level_name outcome_name experiment_name experiment_owner)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      is_single=> "Can't have multiple values",
					      allowed_chars => "Should only contain letters numbers or '_'",
					      factor_exists => "Factor not found",
					      outcome_exists => "Outcome not found",
					      outcome_has_level => "Outcome doesn't have that level",
					      experiment_has_factor => "Factor is not in this experiment",
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    factor_name => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars,
							    ROME::Constraints::factor_exists($c,'factor_owner'),
							   ],
					    factor_owner => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							    ],
					    level_name => [
							   ROME::Constraints::is_single,
							   ROME::Constraints::allowed_chars,
							  ],
					    outcome_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::outcome_exists($c,'experiment_name','experiment_owner'),
							     ROME::Constraints::outcome_has_level($c,'experiment_name','experiment_owner','factor_name', 'factor_owner', 'level_name' ),
							    ],
					    experiment_name => [
								ROME::Constraints::is_single,
								ROME::Constraints::allowed_chars,
								ROME::Constraints::experiment_exists($c,'experiment_owner'),
								ROME::Constraints::experiment_has_factor($c, 'experiment_owner', 'factor_name', 'factor_owner'),
							       ],
					    experiment_owner => [
								 ROME::Constraints::is_single,
								 ROME::Constraints::allowed_chars,
								],

					    },
		    };
  $c->form($dfv_profile);  
}

=item outcome_delete_level

   metadata/outcome/delete_level

   params are:
   factor_name
   factor_owner 
   level_name
   outcome_name
   experiment_name  (experiment defaults to that currently selected.
   experiment_owner

    Note that the outcome name needs to be the actual name, not the display name.

=cut
sub outcome_delete_level :Path('outcome/delete_level'){
    my ($self, $c) = @_;
    $c->stash->{ajax} = 1;
    $c->stash->{template} = 'site/messages';

    unless ($c->request->params->{experiment_name}){
	$c->request->params->{experiment_name} = $c->user->experiment->name;
	$c->request->params->{experiment_owner} = $c->user->experiment->owner->username;
    }


    my $out_lev;
    if ($c->forward('_validate_outcome_delete_level')){
	
	
	#add the level to the outcome
	$out_lev = $c->model('ROMEDB::OutcomeLevel')->find
	    ({
	      outcome_name => $c->request->params->{outcome_name},
	      outcome_experiment_name => $c->request->params->{experiment_name},
	      outcome_experiment_owner => $c->request->params->{experiment_owner},
	      level_factor_name => $c->request->params->{factor_name},
	      level_factor_owner => $c->request->params->{factor_owner},
	      level_name => $c->request->params->{level_name},
	     });
	
	unless ($out_lev){
	    $c->stash->{error_msg} = 'Failed to delete level from outcome';
	return;
	}
	$out_lev->delete;
	
    }
    else{
	$c->stash->{error_msg} = 'Invalid Parameters'; 
	return;
    }

    $c->stash->{status_msg} = 'Deleted '.$c->request->params->{factor_name}.'-'.$c->request->params->{level_name}.' from '.$out_lev->outcome->display_name;
    
}




###


sub _validate_outcome_add_cont_var :Local{
  my ($self, $c) = @_;
  
  my $dfv_profile = {
 		     required => [qw(cont_var_name cont_var_owner cont_var_name cont_var_value experiment_name experiment_owner)],
 		     msgs => {
 			      format => '%s',
 			      constraints => {
 					      is_single=> "Can't have multiple values",
 					      allowed_chars => "Should only contain letters numbers or '_'",
 					      cont_var_exists => "Variable not found",
 					      outcome_exists => "Outcome not found",
 					      not_outcome_has_cont_var => "Outcome already has a value defined for that variable",
 					      experiment_has_cont_var => "Variable is not in this experiment",
 					     },
 			     },
 		     filters => ['trim'],
 		     missing_optional_valid => 1,    
 		     constraint_methods => {
 					    cont_var_name => [
 							      ROME::Constraints::is_single,
 							      ROME::Constraints::allowed_chars,
 							      ROME::Constraints::cont_var_exists($c,'cont_var_owner'),
							     ],
 					    cont_var_owner => [
							       ROME::Constraints::is_single,
 							       ROME::Constraints::allowed_chars,
 							      ],
 					    cont_var_value => [
 							       ROME::Constraints::is_single,
 							       ROME::Constraints::allowed_chars,
							      ],
 					    outcome_name => [
 							     ROME::Constraints::is_single,
 							     ROME::Constraints::allowed_chars,
 							     ROME::Constraints::outcome_exists($c,'experiment_name','experiment_owner'),
 							     ROME::Constraints::not_outcome_has_cont_var($c,'experiment_name','experiment_owner','cont_var_name', 'cont_var_owner' ),
 							    ],
 					    experiment_name => [
 								ROME::Constraints::is_single,
 								ROME::Constraints::allowed_chars,
 								ROME::Constraints::experiment_exists($c,'experiment_owner'),
 								ROME::Constraints::experiment_has_cont_var($c, 'experiment_owner', 'cont_var_name', 'cont_var_owner'),
 							       ],
 					    experiment_owner => [
 								 ROME::Constraints::is_single,
 								 ROME::Constraints::allowed_chars,
 								],
					    
					   },
 		    };
  $c->form($dfv_profile);  
 }

=item outcome_add_cont_var

    metadata/cont_var/add_cont_var

    params are:
    cont_var_name
    cont_var_owner 
    cont_var_value
    outcome_name
    experiment_name  (experiment defaults to that currently selected.
    experiment_owner

     Note that the outcome name needs to be the actual name, not the display name.

=cut
sub outcome_add_cont_var :Path('outcome/add_cont_var'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';
  
  unless ($c->request->params->{experiment_name}){
    $c->request->params->{experiment_name} = $c->user->experiment->name;
    $c->request->params->{experiment_owner} = $c->user->experiment->owner->username;
  }
  
  my $out;
  if ($c->forward('_validate_outcome_add_cont_var')){
    
    
    #add the cont_var to the outcome
    my $cvv = $c->model('ROMEDB::ContVarValue')->create
      ({
	outcome_name => $c->request->params->{outcome_name},
	outcome_experiment_name => $c->request->params->{experiment_name},
	outcome_experiment_owner => $c->request->params->{experiment_owner},
	cont_var_name => $c->request->params->{cont_var_name},
	cont_var_owner => $c->request->params->{cont_var_owner},
	value => $c->request->params->{cont_var_value},
       });
    
    unless ($cvv){
      $c->stash->{error_msg} = 'Failed to add variable to outcome';
      return;
    }
    
    $out = $c->model('ROMEDB::Outcome')->find(
					      $c->request->params->{outcome_name},
					      $c->request->params->{experiment_name},
					      $c->request->params->{experiment_owner}
					     );
    
  }
  else{
    $c->stash->{error_msg} = 'Invalid Parameters'; 
    return;
  }

  $c->stash->{status_msg} = 'Added '.$c->request->params->{cont_var_name}.'-'.$c->request->params->{cont_var_value}.' to '.$out->display_name;
  
}






sub _validate_outcome_delete_cont_var :Local{
  my ($self, $c) = @_;
  
  my $dfv_profile = {
 		     required => [qw(cont_var_name cont_var_owner outcome_name experiment_name experiment_owner)],
 		     msgs => {
 			      format => '%s',
 			      constraints => {
 					      is_single=> "Can't have multiple values",
 					      allowed_chars => "Should only contain letters numbers or '_'",
 					      cont_var_exists => "Variable not found",
 					      outcome_exists => "Outcome not found",
 					      outcome_has_cont_var => "Outcome doesn't have that varaiable",
 					      experiment_has_cont_var => "Variable is not in this experiment",
 					     },
 			     },
 		     filters => ['trim'],
 		     missing_optional_valid => 1,    
 		     constraint_methods => {
 					    cont_var_name => [
 							    ROME::Constraints::is_single,
 							    ROME::Constraints::allowed_chars,
 							    ROME::Constraints::cont_var_exists($c,'cont_var_owner'),
 							   ],
 					    cont_var_owner => [
 							     ROME::Constraints::is_single,
 							     ROME::Constraints::allowed_chars,
 							    ],
 					    level_name => [
 							   ROME::Constraints::is_single,
 							   ROME::Constraints::allowed_chars,
 							  ],
 					    outcome_name => [
 							     ROME::Constraints::is_single,
 							     ROME::Constraints::allowed_chars,
 							     ROME::Constraints::outcome_exists($c,'experiment_name','experiment_owner'),
 							     ROME::Constraints::outcome_has_cont_var($c,'experiment_name','experiment_owner','cont_var_name', 'cont_var_owner' ),
 							    ],
 					    experiment_name => [
 								ROME::Constraints::is_single,
 								ROME::Constraints::allowed_chars,
 								ROME::Constraints::experiment_exists($c,'experiment_owner'),
 								ROME::Constraints::experiment_has_cont_var($c, 'experiment_owner', 'cont_var_name', 'cont_var_owner'),
 							       ],
 					    experiment_owner => [
 								 ROME::Constraints::is_single,
 								 ROME::Constraints::allowed_chars,
 								],
					    
					   },
 		    };
  $c->form($dfv_profile);  
}

=item outcome_delete_cont_var

    metadata/outcome/delete_cont_var

    params are:
    cont_var_name
    cont_var_owner 
    outcome_name
    experiment_name  (experiment defaults to that currently selected.
    experiment_owner

     Note that the outcome name needs to be the actual name, not the display name.

=cut

sub outcome_delete_cont_var :Path('outcome/delete_cont_var'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';
  
  unless ($c->request->params->{experiment_name}){
    $c->request->params->{experiment_name} = $c->user->experiment->name;
 	$c->request->params->{experiment_owner} = $c->user->experiment->owner->username;
  }
  
  
  my $cvv;
  if ($c->forward('_validate_outcome_delete_cont_var')){
	
    
    $cvv = $c->model('ROMEDB::ContVarValue')->find
      ({
	outcome_name => $c->request->params->{outcome_name},
	outcome_experiment_name => $c->request->params->{experiment_name},
	outcome_experiment_owner => $c->request->params->{experiment_owner},
	cont_var_name => $c->request->params->{cont_var_name},
	cont_var_owner => $c->request->params->{cont_var_owner},
       });
    
    unless ($cvv){
      $c->stash->{error_msg} = 'Failed to delete variable from outcome';
      return;
    }
    $cvv->delete;
    
  }
     else{
       $c->stash->{error_msg} = 'Invalid Parameters'; 
       return;
     }

  $c->stash->{status_msg} = 'Deleted '.$c->request->params->{cont_var_name}.' from '.$cvv->outcome->display_name;
  
}






=back

=head1 AUTHOR

Cass Johnston

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
