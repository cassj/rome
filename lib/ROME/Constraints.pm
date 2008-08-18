package ROME::Constraints;

use strict;
use warnings;
use Email::Valid;

=head1 NAME

  ROME::Constraints

=head1 DESCRIPTION

  A collection of Data::FormValidator Constraint methods for ROME forms

  Constraints must be true for the form to pass, so for example if you need
  a username to exist in the database, use the user_exists constraint.

  Currently, the module doesn't actually export anything so you'll need to use
  the fully qualified method name.

  Constraints are named for dfv by their method names, which you can use in 
  your dfv profile to set an error message to show the user should that constraint
  fail. For example, if the user_exists constraint failed, you might tell the user
  that the username does not exist:
  
  my $dfv_profile = {
	     msgs => {
		      constraints => {
				      'user_exists'   => 'That user does not exist',
				     },
		      format => '%s',
		     },
	     constraint_methods => {
				    username => ROME::Constraints::user_exists($c),
				   }
	    };


   In general, you can reverse the meaning of a constraint by prepending not_ to the
   constraint name. For example, if you want a username which isn't currently in use, 
   you could use the not_user_exists constraint. Note that the constraint name (for the
   purposes of dfv msgs) is still the original one (without not_):

  my $dfv_profile = {
	     msgs => {
		      constraints => {
				      'user_exists'   => 'That username is already taken',
				     },
		      format => '%s',
		     },
	     constraint_methods => {
				    username => ROME::Constraints::not_user_exists($c),
				   }
	    };

 

=head2 (not_)user_exists 

  Returns (a closure which returns) true only if the username exists.
  Requires $c as an argument.

  not_user_exists($c) does the opposite

=cut 

sub user_exists{
  my $c = shift;
  my $inverse = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('user_exists');
    my $val = $dfv->get_current_constraint_value();
    my $exists = $c->model('ROMEDB::Person')->find($val);
    return ($exists xor $inverse);
  }

}


=head (not_)experiment_exists

Returns (a closure which returns) true only if an experiment with this name
exists for the given user. (not_experiment_exists does the reverse)

Needs arguments:
1: the $c catalyst context
2: the name of the form field containing the username of the experiment owner

=cut

sub experiment_exists{
  my ($c,$owner_field,$inverse) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('experiment_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::Experiment')->find($val, $data->{$owner_field});
    return $exists ? 1:0;
  }

}



sub not_experiment_exists{
  my ($c,$owner_field,$inverse) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_experiment_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::Experiment')->find($val, $data->{$owner_field});
    return $exists ? 0:1;
  }

}


=head2 experiment_in_workgroup

  Checks that an experiment is shared with the given workgroup

  Expects Catalyst context, experiment owner field, workgroup name field

  ROME::Constraints::experiment_in_workgroup($c,'experiment_owner', 'workgroup_name');

=cut


sub experiment_in_workgroup{
    my ($c,$owner_field, $wg_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_in_workgroup');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $wg = $data->{$wg_field};
	my $exists = $c->model('ROMEDB::ExperimentWorkgroup')->find($name,$owner,$wg);
	return $exists ? 1:0;
    }
}





=head2 experiment_not_in_workgroup

  Checks that an experiment is not shared with the given workgroup

  Expects Catalyst context, experiment owner field, workgroup name field

  ROME::Constraints::experiment_not_in_workgroup($c,'experiment_owner', 'workgroup_name');

=cut


sub experiment_not_in_workgroup{
    my ($c,$owner_field, $wg_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_not_in_workgroup');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $wg = $data->{$wg_field};
	my $exists = $c->model('ROMEDB::ExperimentWorkgroup')->find($name,$owner,$wg);
	return $exists ? 0:1;
    }
}






=head2 experiment_public

  Checks that an experiment status is 'public'
  
  Expects Catalyst context, experiment owner field

  ROME::Constraints::experiment_public($c,'experiment_owner')

=cut


sub experiment_public{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_public');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $expt = $c->model('ROMEDB::Experiment')->find($name,$owner);
	return $expt->status eq 'public' ? 1:0;
    }
}





=head2 experiment_not_public

  Checks that an experiment status is not 'public' 
  
  Expects Catalyst context, experiment owner field

  ROME::Constraints::experiment_not_public($c,'experiment_owner')

=cut


sub experiment_not_public{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_not_public');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $expt = $c->model('ROMEDB::Experiment')->find($name,$owner);
	return $expt->status eq 'public' ? 0:1;
    }
}






=head2 experiment_shared

  Checks that an experiment status is 'shared'
  
  Expects Catalyst context, experiment owner field

  ROME::Constraints::experiment_shared($c,'experiment_owner')

=cut


sub experiment_shared{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_shared');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $expt = $c->model('ROMEDB::Experiment')->find($name,$owner);
	return $expt->status eq 'shared' ? 1:0;
    }
}





=head2 experiment_not_shared

  Checks that an experiment status is not 'shared' 
  
  Expects Catalyst context, experiment owner field

  ROME::Constraints::experiment_not_shared($c,'experiment_owner')

=cut


sub experiment_not_shared{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_not_shared');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $expt = $c->model('ROMEDB::Experiment')->find($name,$owner);
	return $expt->status eq 'shared' ? 0:1;
    }
}



=head2  (not_)experiment_has_factor

  Checks that the given experiment has the given factor. 
  Call on experiment_name with params
    1. Catalyst context
    2. name of form field containing the experiment owner username
    3. name of the form field containing the factor name
    4. name of the form field containing the factor owner username

=cut

sub experiment_has_factor{
    my ($c,$owner_field, $fac_name_field, $fac_owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_has_factor');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
        my $fac_name = $data->{$fac_name_field};
	my $fac_owner = $data->{$fac_owner_field};
	my $exists = $c->model('ROMEDB::FactorExperiment')->find($fac_name,$fac_owner, $name,$owner);
	return $exists ? 1:0;
    }
}


sub not_experiment_has_factor{
    my ($c,$owner_field, $fac_name_field, $fac_owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('not_experiment_has_factor');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
        my $fac_name = $data->{$fac_name_field};
	my $fac_owner = $data->{$fac_owner_field};
	my $exists = $c->model('ROMEDB::FactorExperiment')->find($fac_name,$fac_owner, $name,$owner);
	return $exists ? 0:1;
    }
}





=head2  (not_)experiment_has_cont_var

  Checks that the given experiment has the given cont_var. 
  Call on experiment_name with params
    1. Catalyst context
    2. name of form field containing the experiment owner username
    3. name of the form field containing the cont_var name
    4. name of the form field containing the cont_var owner username

=cut

sub experiment_has_cont_var{
    my ($c,$owner_field, $cv_name_field, $cv_owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_has_cont_var');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
        my $cv_name = $data->{$cv_name_field};
	my $cv_owner = $data->{$cv_owner_field};
	my $exists = $c->model('ROMEDB::ContVarExperiment')->find($cv_name,$cv_owner, $name,$owner);
	return $exists ? 1:0;
    }
}



sub not_experiment_has_cont_var{
    my ($c,$owner_field, $cv_name_field, $cv_owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('experiment_has_cont_var');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
        my $cv_name = $data->{$cv_name_field};
	my $cv_owner = $data->{$cv_owner_field};
	my $exists = $c->model('ROMEDB::ContVarExperiment')->find($cv_name,$cv_owner, $name,$owner);
	return $exists ? 0:1;
    }
}




=head (not_)outcome_exists

  Checks if the given outcome exists

Needs arguments:
1: the $c catalyst context
2: the name of the form field containing the name of the experiment to which 
   this outcome belongs
3: the name of the form field containing the username of the owner of the
   experiment to which this outcome belongs

Experiment defaults to the currently selected one

=cut

sub outcome_exists{
  my ($c,$expt_name_field,$expt_owner_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('outcome_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my ($expt_name, $expt_owner);
    if($expt_name_field && $expt_owner_field ){
      $expt_name = $data->{$expt_name_field};
      $expt_owner = $data->{$expt_owner_field};
    }
    else{
      $expt_name = $c->user->experiment->name;
      $expt_owner = $c->user->experiment->owner->username;
    }
    my $exists = $c->model('ROMEDB::Outcome')->find($val, $expt_name, $expt_owner);
    return $exists ? 1:0;
  }

}


sub not_outcome_exists{
  my ($c,$expt_name_field,$expt_owner_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_outcome_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my ($expt_name, $expt_owner);
    if($expt_name_field && $expt_owner_field ){
      $expt_name = $data->{$expt_name_field};
      $expt_owner = $data->{$expt_owner_field};
    }
    else{
      $expt_name = $c->user->experiment->name;
      $expt_owner = $c->user->experiment->owner->username;
    }
    my $exists = $c->model('ROMEDB::Outcome')->find($val, $expt_name, $expt_owner);
    return $exists ? 0:1;
  }

}


=head2  (not_)outcome_has_factor

  Checks that the given outcome has a level of this factor

  Call on the outcome name field with params
  1: Catalyst context
  2: name of the field containing the name of the experiment to 
     which this outcome belongs
  3: name of the field containing the username of the owner of 
     the experiment to which this outcome belongs
  4: name of the field containing the factor name
  5: name of the field containing the factor owner.

=cut

sub outcome_has_factor{
  my ($c,$expt_name_field, $expt_owner_field, $factor_name_field, $factor_owner_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('outcome_has_factor');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $expt_name = $data->{$expt_name_field};
    my $expt_owner = $data->{$expt_owner_field};
    my $factor_name = $data->{$factor_name_field};
    my $factor_owner = $data->{$factor_owner_field};
    #not as simple as the others. need to get the levels of the factor and see if any of them
    #are associated with the outcome.
    
    #retrieve the outcome
    my $out = $c->model('ROMEDB::Outcome')->find($val, $expt_name, $expt_owner);
    
    #get the factors it has levels for
    my %levels = map {$_->factor->name => $_->factor->owner->username} $out->levels;
    
    return ($levels{$factor_name} && $levels{$factor_name} eq $factor_owner)? 1:0;

  }

}



sub not_outcome_has_factor{
  my ($c,$expt_name_field, $expt_owner_field, $factor_name_field, $factor_owner_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_outcome_has_factor');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $expt_name = $data->{$expt_name_field};
    my $expt_owner = $data->{$expt_owner_field};
    my $factor_name = $data->{$factor_name_field};
    my $factor_owner = $data->{$factor_owner_field};
    #not as simple as the others. need to get the levels of the factor and see if any of them
    #are associated with the outcome.
 
    #retrieve the outcome
    my $out = $c->model('ROMEDB::Outcome')->find($val, $expt_name, $expt_owner);
    
    my @levels = $out->levels;

    #get the factors it has levels for
    my %levels = map {$_->factor->name => $_->factor->owner->username} $out->levels;
    
    return ($levels{$factor_name} && $levels{$factor_name} eq $factor_owner)? 0:1;

  }

}




=head2  (not_)outcome_has_level

  Checks that the given outcome has the given level of a factor

  Call on the outcome name field with params
  1: Catalyst context
  2: name of the field containing the name of the experiment to 
     which this outcome belongs
  3: name of the field containing the username of the owner of 
     the experiment to which this outcome belongs
  4: name of the field containing the factor name
  5: name of the field containing the factor owner.
  6: name of the field containing the level name.

=cut

sub outcome_has_level{
  my ($c,$expt_name_field, $expt_owner_field, $factor_name_field, $factor_owner_field, $level_name_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('outcome_has_level');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $expt_name = $data->{$expt_name_field};
    my $expt_owner = $data->{$expt_owner_field};
    my $factor_name = $data->{$factor_name_field};
    my $factor_owner = $data->{$factor_owner_field};
    my $level_name = $data->{$level_name_field};


    my $exists = $c->model('ROMEDB::OutcomeLevel')->find({
	outcome_name => $val,
	outcome_experiment_name => $expt_name, 
	outcome_experiment_owner => $expt_owner,
	level_factor_name => $factor_name,
	level_factor_owner =>$factor_owner,
	level_name => $level_name,
    });

    return $exists? 1:0;

  }

}




sub not_outcome_has_level{
  my ($c,$expt_name_field, $expt_owner_field, $factor_name_field, $factor_owner_field, $level_name_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_outcome_has_level');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $expt_name = $data->{$expt_name_field};
    my $expt_owner = $data->{$expt_owner_field};
    my $factor_name = $data->{$factor_name_field};
    my $factor_owner = $data->{$factor_owner_field};
    my $level_name = $data->{$level_name_field};

    my $exists = $c->model('ROMEDB::OutcomeLevel')->find($val,
							 $expt_name, 
							 $expt_owner,
							 $factor_name,
							 $factor_owner,
							 $level_name,
    );
    
    return $exists? 0:1;

  }

}



=head2  (not_)outcome_has_cont_var

  Checks that the given outcome has a value for the given cont_var

  Call on the outcome name field with params
  1: Catalyst context
  2: name of the field containing the name of the experiment to 
     which this outcome belongs
  3: name of the field containing the username of the owner of 
     the experiment to which this outcome belongs
  4: name of the field containing the cont_var name
  5: name of the field containing the cont_var owner.

=cut

sub outcome_has_cont_var{
  my ($c,$expt_name_field, $expt_owner_field, $cont_var_name_field, $cont_var_owner_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('outcome_has_cont_var');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $expt_name = $data->{$expt_name_field};
    my $expt_owner = $data->{$expt_owner_field};
    my $cont_var_name = $data->{$cont_var_name_field};
    my $cont_var_owner = $data->{$cont_var_owner_field};
    
    my $exists = $c->model('ROMEDB::ContVarValue')->find
      ({
	cont_var_name => $cont_var_name,
	cont_var_owner => $cont_var_owner,
	outcome_name   => $val,
	outcome_experiment_name => $expt_name,
	outcome_experiment_owner => $expt_owner
       });
    
    return $exists?1:0;

  }

}




sub not_outcome_has_cont_var{
  my ($c,$expt_name_field, $expt_owner_field, $cont_var_name_field, $cont_var_owner_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_outcome_has_cont_var');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $expt_name = $data->{$expt_name_field};
    my $expt_owner = $data->{$expt_owner_field};
    my $cont_var_name = $data->{$cont_var_name_field};
    my $cont_var_owner = $data->{$cont_var_owner_field};
    
    my $exists = $c->model('ROMEDB::ContVarValue')->find
      ({
	cont_var_name => $cont_var_name,
	cont_var_owner => $cont_var_owner,
	outcome_name   => $val,
	outcome_experiment_name => $expt_name,
	outcome_experiment_owner => $expt_owner
       });
    
    return $exists?0:1;

  }

}




=head2 user_owns_workgroup

  Returns (a closure which returns) true only if the current
  user is the owner of the workgroup of this name 

  Needs $c as an argument.

=cut

sub user_owns_workgroup{
  my $c = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('user_owns_workgroup');
    my $val = $dfv->get_current_constraint_value();
    my $wg = $c->model('ROMEDB::Workgroup')->find($val);
    
    return $c->user->username eq $wg->leader->username;
  }
}


=head2 not_user_owns_workgroup

  Returns (a closure which returns) true only if the 
  current user is not the owner of the workgroup

  Needs $c as an argument.

=cut

sub not_user_owns_workgroup{
  my $c = shift;
  
  return sub {
    my $dfv = shift;
    $dfv->name_this('not_user_owns_workgroup');
    my $val = $dfv->get_current_constraint_value();
    my $wg = $c->model('ROMEDB::Workgroup')->find($val);
    
    return !($c->user->username eq $wg->leader->username);
  }
}


=head2 not_this_user_owns_workgroup

    Returns (a closure which returns) true only if the
    person in this field is not the owner of the group in 
    the specified field

=cut

sub not_this_user_owns_workgroup{
    my ($c, $wg_field) = @_;
    die "You must specify a workgroup field" unless $wg_field;
    
    return sub {
	my $dfv = shift;
	$dfv->name_this('not_this_user_owns_workgroup');
	my $username = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $wg = $c->model('ROMEDB::Workgroup')->find($data->{$wg_field});
	return ($wg->leader->username eq $username) ? 0 : 1;
    }
    
}

=head2 (not_)allowed_chars

  Returns (a closure which returns) true only if the string
  contains allowed chars (alphanumeric or underscore, no spaces)

=cut

sub allowed_chars{
  my $inverse = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('allowed_chars');
    my $val = $dfv->get_current_constraint_value();
    return ($val =~/^[\d\w\.]+$/ xor $inverse);  
  }
 
}

=head2 (not_)allowed_chars_plus

  As for allowed_chars, but also permits whitespace and bits of punctuation

=cut

sub allowed_chars_plus{
  my $inverse = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('allowed_chars_plus');
    my $val = $dfv->get_current_constraint_value();
    return ($val =~/^[\w\s,\._\-\(\)]+$/ xor $inverse);  
  }
 
}

=head2 (not_)allowed_pwd_length

  Returns (a closure which returns) true only if the string
  contains between 6 and 10 characters of which none are spaces.

=cut
sub allowed_pwd_length{
  my $inverse = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('allowed_pwd_length');
    my $val = $dfv->get_current_constraint_value();
    return ( ((length($val)>5 ) and (length($val)< 11) ) 
	     xor $inverse ); 
  }
 

}


=head2 (not_)allowed_pwd_chars

  Returns (a closure which returns) true only if the string
  contains word characters, numbers, underscore or hyphen.

=cut
sub allowed_pwd_chars{
  my $inverse = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('allowed_pwd_chars');
    my $val = $dfv->get_current_constraint_value();
    return ($val =~/^[\d\w\-]+$/ xor $inverse);

  }
 

}




=head2 (not_)strings_match

  Returns (a closure which returns) true only if the current field
  and another specified field contain exactly the same string value.

  Use in dfv profile like:

  password => [
         	    ROME::Constraints::strings_match(
			       {fields => [qw/password2/]} ),
              ]

=cut

sub strings_match{

  my $field2 = shift;
  my $inverse = shift;

  return sub {
   my $dfv = shift;
   $dfv->name_this('strings_match');
   my $val = $dfv->get_current_constraint_value();
   my $data = $dfv->get_filtered_data;
   return ( ($data->{$field2} eq $val) xor $inverse );
  }
}


=head2 valid_email

  Returns (a closure which returns) true only if this is a valid email.

=cut
sub valid_email{

  return sub {
    my $dfv = shift;
    my $val = $dfv->get_current_constraint_value();
    $dfv->name_this('valid_email');
    my $localhost = $val =~/.+\@localhost/;
    return (Email::Valid->address($val) || $localhost); 
  }
}


=head2 valid_pubmed

  Returns (a closure which returns) true only if this looks like a pubmed ID

=cut

sub valid_pubmed{
  my $inverse = shift;

  return sub{
    my $dfv = shift;
    my $val = $dfv->get_current_constraint_value();
    $dfv->name_this('valid_pubmed');
    return ($val =~/^[\d]+$/  xor $inverse);
  }
}


=head2 valid_experiment_status

  Returns (a closure which returns) true only if this is a valid
  experiment status (public, private or shared)

=cut 

sub valid_experiment_status{
  my $inverse = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('valid_experiment_status');
    my $val = $dfv->get_current_constraint_value();
    my $ok = $val =~/[public|shared|private]/;
    return ($ok xor $inverse);
  }

}


=head2 (not_)workgroup_exists 

  Returns (a closure which returns) true only if the workgroup exists.
  Requires $c as an argument.

  not_workgroup_exists($c) does the opposite

=cut 

sub workgroup_exists{
  my $c = shift;
  my $inverse = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('workgroup_exists');
    my $val = $dfv->get_current_constraint_value();
    my $exists = $c->model('ROMEDB::Workgroup')->find($val);
    return ($exists xor $inverse);
  }

}


=head2 is_current_user

  Returns (a closure which returns) true only if the username
  given is that of the current user

  Requires $c as an argument.

=cut

sub is_current_user{
  my $c = shift;
  my $inverse = shift;
  
  return sub {
    my $dfv = shift;
    $dfv->name_this('is_current_user');
    my $val = $dfv->get_current_constraint_value();
    my $ok = $c->user->username eq $val;
    return ($ok xor $inverse);
  }

}

=head2 is_current_user_or_admin

  Returns (a closure which returns) true if the username given
  is that of the current user or is an administrator

  Requires $c as an argument


=cut
sub is_current_user_or_admin{
  my $c = shift;
  my $inverse = shift;
  
  return sub {
    my $dfv = shift;
    $dfv->name_this('is_current_user_or_admin');
    my $val = $dfv->get_current_constraint_value();
    my $ok = $c->user->username eq $val || $c->check_user_roles('admin');
    return ($ok xor $inverse);
  }

}

=head2 can_update_workgroup

=cut

sub user_can_update_workgroup{
  my $c = shift;
  my $inverse = shift;
  
  return sub{
    my $dfv = shift;
    $dfv->name_this('user_can_update_workgroup');
    my $val = $dfv->get_current_constraint_value();
    my $wg = $c->model('ROMEDB::Workgroup')->find($val);
    #if the workgroup doesn't exist that's a diff prob. This constraint
    #doesn't fail.
    return 1 unless $wg;
    my $ok = $c->user->username eq $wg->leader->username || $c->check_user_roles('admin');
    return ($ok xor $inverse);
  };
}


=head2 user_is_invited

Returns (a closure which returns) true if the current user has an entry 
in the workgroup_invite table corresponding to this workgroup name.

=cut

sub user_is_invited{
    my $c = shift;
 
    return sub{
	my $dfv = shift;
	$dfv->name_this('user_is_invited');
	my $val = $dfv->get_current_constraint_value();
	my $exists = $c->model('ROMEDB::WorkgroupInvite')->find({
	    person=>$c->user->username,
	    workgroup=>$val
								   });
	return $exists;
    }
}


=head2 user_in_workgroup

  Returns true if the user is in the workgroup 
  Needs the name of the param with the workgroup name
  and the catalyst context

  user_in_workgroup($wg_field,$c);

=cut

sub user_in_workgroup{
  my $wg_field = shift;
  my $c = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('user_in_workgroup');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::PersonWorkgroup')->find({person => $val,
							     workgroup => $data->{$wg_field}});

    return $exists;

  };
}

=head2 not_user_in_workgroup
    
    Returns true if teh user is not in the workgroup
    Needs the name of the param containing the workgroup name
    and the catalyst context object.

=cut
sub not_user_in_workgroup{
  my $wg_field = shift;
  my $c = shift;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_user_in_workgroup');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::PersonWorkgroup')->find({person => $val,
							     workgroup => $data->{$wg_field}});

    return !$exists;

  };
}


=head2 current_user_in_workgroup

  Returns (a closure which returns) true only if the
  current user is a member of the workgroup

  Takes $c as an argument

=cut

sub current_user_in_workgroup{
  my $c = shift;
  
  return sub{
    my $dfv = shift;
    $dfv->name_this('current_user_in_workgroup');
    my $val = $dfv->get_current_constraint_value();
    my $exists = $c->model('ROMEDB::PersonWorkgroup')->find({
							     person=>$c->user->username,
							     workgroup=>$val,
							    });
    return $exists;
  }
}


=head2 not_current_user_in_workgroup

  Returns (a closure which returns) true only if the 
  current user is not a member of the workgroup

  Takes $c as an argument

=cut

sub not_current_user_in_workgroup{
  my $c = shift;
  
  return sub{
    my $dfv = shift;
    $dfv->name_this('not_current_user_in_workgroup');
    my $val = $dfv->get_current_constraint_value();
    my $exists = $c->model('ROMEDB::PersonWorkgroup')->find({
							     person=>$c->user->username,
							     workgroup=>$val,
							    });
    return !$exists;
  }
}




=head2 not_workgroup_join_pending

  Returns (a closure which returns) true only if the
  current user does not have a join pending on this workgroup

  Takes $c as an argument

=cut

sub not_workgroup_join_pending{
  my $c = shift;
  
  return sub{
    my $dfv = shift;
    $dfv->name_this('not_workgroup_join_pending');
    my $val = $dfv->get_current_constraint_value();
    my $exists = $c->model('ROMEDB::WorkgroupJoinRequest')->find({
	person=>$c->user->username,
	workgroup=>$val,
								 });
    return !$exists;
  }
}



sub workgroup_join_pending{
  my $c = shift;
  
  return sub{
    my $dfv = shift;
    $dfv->name_this('workgroup_join_pending');
    my $val = $dfv->get_current_constraint_value();
    my $exists = $c->model('ROMEDB::WorkgroupJoinRequest')->find({
	person=>$c->user->username,
	workgroup=>$val,
								 });
    return $exists;
  }
}





=head2 not_workgroup_invite_pending

  Returns (a closure which returns) true only if the
  user does not have an invite pending on this workgroup

  Takes $c as an argument

=cut

sub not_workgroup_invite_pending{
  my $c = shift;
  my $wg_field = shift;
  die "no workgroup field supplied" unless $wg_field;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_workgroup_invite_pending');
    my $person = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $wg = $data->{$wg_field};
    my $exists = $c->model('ROMEDB::WorkgroupInvite')->find({
	person=> $person,
	workgroup=>$wg,
								 });
    return !$exists;
  }
}



=head2 workgroup_invite_pending

  Returns (a closure which returns) true only if the
  user has an invite pending on this workgroup

  Takes $c as an argument

=cut

sub workgroup_invite_pending{
  my $c = shift;
  my $wg_field = shift;
  die "no workgroup field supplied" unless $wg_field;

  return sub{
    my $dfv = shift;
    $dfv->name_this('workgroup_invite_pending');
    my $person = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $wg = $data->{$wg_field};
    my $exists = $c->model('ROMEDB::WorkgroupInvite')->find({
	person=> $person,
	workgroup=>$wg,
								 });
    return $exists;
  }
}



=head2 (not_)factor_exists

  call on the factor_name param. 
  expects the cat context and the name of the parameter 
  that contains the username of the owner as arguments.

=cut
sub factor_exists{
    my $c = shift;
    my $owner_field = shift;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_exists');
	my $val = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $exists = $c->model('ROMEDB::Factor')->find($val,$owner);
	return $exists ? 1:0;
  }
}


sub not_factor_exists{
    my $c = shift;
    my $owner_field = shift;

    return sub{
	my $dfv = shift;
	$dfv->name_this('not_factor_exists');
	my $val = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $exists = $c->model('ROMEDB::Factor')->find($val,$owner);
	return $exists ? 0:1;
  }
}





=head2 (not_)level_exists

  call on the level_name param. 
  expects the cat context and the field names of the 
  factor_name and factor_owner as arguments

=cut
sub level_exists{
    my ($c, $factor_name_field, $factor_owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('level_exists');
	my $val = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $factor_name = $data->{$factor_name_field};
	my $factor_owner = $data->{$factor_owner_field};
	my $exists = $c->model('ROMEDB::Level')->find($val,$factor_name,$factor_owner);
	return $exists ? 1:0;
  }
}



sub not_level_exists{
    my ($c, $factor_name_field, $factor_owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('level_exists');
	my $val = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $factor_name = $data->{$factor_name_field};
	my $factor_owner = $data->{$factor_owner_field};
	my $exists = $c->model('ROMEDB::Level')->find
	  ({
	    name => $val,
	    factor_name => $factor_name,
	    factor_owner => $factor_owner,
	   });
	return $exists ? 0:1;
  }
}


=head2 factor_in_experiment

  Checks that a factor is associated with the 
  given experiment
  
  Expects Catalyst context, factor owner field, experiment DBIC object as params:

  ROME::Constraints::factor_not_in_experiment($c,'factor_owner', $c->user->experiment)

=cut


sub factor_in_experiment{
    my ($c,$owner_field, $expt) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_in_experiment');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $exists = $c->model('ROMEDB::FactorExperiment')->find(
								 $name,
								 $owner,
								 $expt->name,
								 $expt->owner->username);
	return $exists ? 1:0;
    }
}




=head2 factor_not_in_experiment

  Checks that a factor is not associated with the 
  given experiment
  
  Expects Catalyst context, factor owner field, experiment DBIC object as params:

  ROME::Constraints::factor_not_in_experiment($c,'factor_owner', $c->user->experiment)

=cut


sub factor_not_in_experiment{
    my ($c,$owner_field, $expt) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_not_in_experiment');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $exists = $c->model('ROMEDB::FactorExperiment')->find(
								 $name,
								 $owner,
								 $expt->name,
								 $expt->owner->username);
	return $exists ? 0:1;
    }
}





=head2 factor_in_workgroup

  Checks that a factor is shared with the given workgroup

  Expects Catalyst context, factor owner field, workgroup name field

  ROME::Constraints::factor_in_workgroupi$c,'factor_owner', 'workgroup_name');

=cut


sub factor_in_workgroup{
    my ($c,$owner_field, $wg_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_in_workgroup');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $wg = $data->{$wg_field};
	my $exists = $c->model('ROMEDB::FactorWorkgroup')->find($name,$owner,$wg);
	return $exists ? 1:0;
    }
}





=head2 factor_not_in_workgroup

  Checks that a factor is not shared with the given workgroup

  Expects Catalyst context, factor owner field, workgroup name field

  ROME::Constraints::factor_not_in_workgroupi$c,'factor_owner', 'workgroup_name');

=cut


sub factor_not_in_workgroup{
    my ($c,$owner_field, $wg_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_not_in_workgroup');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $wg = $data->{$wg_field};
	my $exists = $c->model('ROMEDB::FactorWorkgroup')->find($name,$owner,$wg);
	return $exists ? 0:1;
    }
}






=head2 factor_public

  Checks that a factor status is 'public'
  
  Expects Catalyst context, factor owner field

  ROME::Constraints::factor_public($c,'factor_owner')

=cut


sub factor_public{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_public');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $fac = $c->model('ROMEDB::Factor')->find($name,$owner);
	return $fac->status eq 'public' ? 1:0;
    }
}





=head2 factor_not_public

  Checks that a factor status is not 'public' 
  
  Expects Catalyst context, factor owner field

  ROME::Constraints::factor_not_public($c,'factor_owner')

=cut


sub factor_not_public{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_not_public');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $fac = $c->model('ROMEDB::Factor')->find($name,$owner);
	return $fac->status eq 'public' ? 0:1;
    }
}






=head2 factor_shared

  Checks that a factor status is 'shared'
  
  Expects Catalyst context, factor owner field

  ROME::Constraints::factor_shared($c,'factor_owner')

=cut


sub factor_shared{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_shared');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $fac = $c->model('ROMEDB::Factor')->find($name,$owner);
	return $fac->status eq 'shared' ? 1:0;
    }
}





=head2 factor_not_shared

  Checks that a factor status is not 'shared' 
  
  Expects Catalyst context, factor owner field

  ROME::Constraints::factor_not_shared($c,'factor_owner')

=cut


sub factor_not_shared{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('factor_not_shared');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $fac = $c->model('ROMEDB::Factor')->find($name,$owner);
	return $fac->status eq 'shared' ? 0:1;
    }
}







=head2 (not_)cont_var_exists

  call on the cont_var_name param. 
  expects the cat context and the name of the parameter 
  that contains the username of the owner as arguments.

=cut
sub cont_var_exists{
    my $c = shift;
    my $owner_field = shift;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_exists');
	my $val = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $exists = $c->model('ROMEDB::ContVar')->find($val,$owner);
	return $exists ? 1:0;
  }
}


sub not_cont_var_exists{
    my $c = shift;
    my $owner_field = shift;

    return sub{
	my $dfv = shift;
	$dfv->name_this('not_cont_var_exists');
	my $val = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $exists = $c->model('ROMEDB::ContVar')->find($val,$owner);
	return $exists ? 0:1;
  }
}



=head2 cont_var_in_experiment

  Checks that a continuous variable is associated with the 
  given experiment
  
  Expects Catalyst context, variable owner field, experiment DBIC object as params:

  ROME::Constraints::cont_var_not_in_experiment($c,'cont_var_owner', $c->user->experiment)

=cut


sub cont_var_in_experiment{
    my ($c,$owner_field, $expt) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_in_experiment');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $exists = $c->model('ROMEDB::ContVarExperiment')->find(
								  $name,
								  $owner,
								  $expt->name,
								  $expt->owner->username);
	return $exists ? 1:0;
    }
}




=head2 cont_var_not_in_experiment

  Checks that a continuous variable is not associated with the 
  given experiment
  
  Expects Catalyst context, vraiable owner field, experiment DBIC object as params:

  ROME::Constraints::cont_var_not_in_experiment($c,'cont_var_owner', $c->user->experiment)

=cut


sub cont_var_not_in_experiment{
    my ($c,$owner_field, $expt) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_not_in_experiment');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $exists = $c->model('ROMEDB::ContVarExperiment')->find(
								  $name,
								  $owner,
								  $expt->name,
								  $expt->owner->username);
	return $exists ? 0:1;
    }
}





=head2 cont_var_in_workgroup

  Checks that a continuous variable is shared with the given workgroup

  Expects Catalyst context, variable owner field, workgroup name field

  ROME::Constraints::cont_var_in_workgroupi$c,'cont_var_owner', 'workgroup_name');

=cut


sub cont_var_in_workgroup{
    my ($c,$owner_field, $wg_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_in_workgroup');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $wg = $data->{$wg_field};
	my $exists = $c->model('ROMEDB::ContVarWorkgroup')->find($name,$owner,$wg);
	return $exists ? 1:0;
    }
}





=head2 cont_var_not_in_workgroup

  Checks that a cont_var is not shared with the given workgroup

  Expects Catalyst context, variable owner field, workgroup name field

  ROME::Constraints::cont_var_not_in_workgroupi$c,'cont_var_owner', 'workgroup_name');

=cut


sub cont_var_not_in_workgroup{
    my ($c,$owner_field, $wg_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_not_in_workgroup');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $wg = $data->{$wg_field};
	my $exists = $c->model('ROMEDB::ContVarWorkgroup')->find($name,$owner,$wg);
	return $exists ? 0:1;
    }
}





=head2 cont_var_public

  Checks that a cont_var status is 'public'
  
  Expects Catalyst context, cont_var owner field

  ROME::Constraints::cont_var_public($c,'cont_var_owner')

=cut


sub cont_var_public{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_public');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $cv = $c->model('ROMEDB::ContVar')->find($name,$owner);
	return $cv->status eq 'public' ? 1:0;
    }
}





=head2 cont_var_not_public

  Checks that a cont_var status is not 'public' 
  
  Expects Catalyst context, cont_var owner field

  ROME::Constraints::cont_var_not_public($c,'cont_var_owner')

=cut


sub cont_var_not_public{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_not_public');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $cv = $c->model('ROMEDB::ContVar')->find($name,$owner);
	return $cv->status eq 'public' ? 0:1;
    }
}






=head2 cont_var_shared

  Checks that a cont_var status is 'shared'
  
  Expects Catalyst context, cont_var owner field

  ROME::Constraints::cont_var_shared($c,'cont_var_owner')

=cut


sub cont_var_shared{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_shared');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $cv = $c->model('ROMEDB::ContVar')->find($name,$owner);
	return $cv->status eq 'shared' ? 1:0;
    }
}





=head2 cont_var_not_shared

  Checks that a cont_var status is not 'shared' 
  
  Expects Catalyst context, cont_var owner field

  ROME::Constraints::cont_var_not_shared($c,'cont_var_owner')

=cut


sub cont_var_not_shared{
    my ($c,$owner_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('cont_var_not_shared');
	my $name = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $owner = $data->{$owner_field};
	my $cv = $c->model('ROMEDB::ContVar')->find($name,$owner);
	return $cv->status eq 'shared' ? 0:1;
    }
}


=head2 is_number

   Checks if a value is a real number

=cut
sub is_number{
    return sub{
	my $dfv = shift;
	$dfv->name_this('is_number');
	my $val = $dfv->get_current_constraint_value();
	return $val =~/^\d+\.?(\d+)?$/ ? 1:0;
    }
}

=head2 is_integer

    Checks if a value is an integer

=cut
sub is_integer{
    return sub{
	my $dfv = shift;
	$dfv->name_this('is_integer');
	my $val = $dfv->get_current_constraint_value();
	return $val =~/^\d+$/ ? 1:0;
    }
}


=head2 is_more_than

   Checks if a value is > $n
    ROME::Constraints::is_more_than($n)

=cut

sub is_more_than{
    my $n = shift;
    return sub{
	my $dfv = shift;
	$dfv->name_this('is_more_than');
	my $val = $dfv->get_current_constraint_value();
	return $val > $n;
    }
}



=head2 is_less_than

   Checks if a value is < $n
    ROME::Constraints::is_less_than($n)

=cut

sub is_less_than{
    my $n = shift;
    warn $n;
    return sub{
	my $dfv = shift;
	$dfv->name_this('is_less_than');
	my $val = $dfv->get_current_constraint_value();
	return $val < $n ? 1:0;
    }
}


=head2 is_more_than_inc

   Checks if a value is >= $n
    ROME::Constraints::is_more_than_inc($n)

=cut

sub is_more_than_inc{
    my $n = shift;
    return sub{
	my $dfv = shift;
	$dfv->name_this('is_more_than_inc');
	my $val = $dfv->get_current_constraint_value();
	return $val >= $n;
    }
}



=head2 is_less_than_inc

   Checks if a value is < $n
    ROME::Constraints::is_less_than_inc($n)

=cut

sub is_less_than_inc{
    my $n = shift;
    return sub{
	my $dfv = shift;
	$dfv->name_this('is_less_than_inc');
	my $val = $dfv->get_current_constraint_value();
	return $val <= $n;
    }
}


=head2 is_boolean

  Checks if a value is either 1 or 0

=cut
sub is_boolean{
    return sub{
	my $dfv = shift;
	$dfv->name_this('is_boolean');
	my $val = $dfv->get_current_constraint_value();
	return $val =~/^[1|0]$/ ? 1:0;
    }
}


=head2 is_single

  Checks to see if there is only a single value for this parameter

=cut
sub is_single{
    return sub{
	my $dfv = shift;
	$dfv->name_this('is_single');
	my $field = $dfv->get_current_constraint_field;
	my $data = $dfv->get_filtered_data;
        my $test = $data->{$field};
	return ref $test ? 0:1;
    }
}


sub not_is_single{
    return sub{
	my $dfv = shift;
	$dfv->name_this('not_is_single');
	my $field = $dfv->get_current_constraint_field;
	my $data = $dfv->get_filtered_data;
        my $test = $data->{$field};
	return ref $test ? 1:0;
    }
}

=head2 is_one_of

  Checks that the value is one of the supplied list
    ROME::Constraints::is_one_of('foo','bar');

=cut
sub is_one_of{
    my %lookup = map{$_=>1} @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('is_single');
	my $val = $dfv->get_current_constraint_value;
	return $lookup{$val}
    }
}





=head (not_)component_exists

Returns (a closure which returns) true only if the specified component
exists

Call on the component_name field.

Needs arguments:
1: the $c catalyst context
2: the name of the form field containing the component version

=cut

sub component_exists{
  my ($c,$version_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('component_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::Component')->find($val, $data->{$version_field});
    return $exists ? 1:0;
  }

}

sub not_component_exists{
  my ($c,$version_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_component_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::Component')->find($val, $data->{$version_field});
    return $exists ? 0:1;
  }

}






=head (not_)process_exists

Returns (a closure which returns) true only if the specified process
exists

Call on the process_name field.

Needs arguments:
1: the $c catalyst context
2: the name of the form field containing the process_component_name
3: the name of the form field containing the process_component_version

=cut

sub process_exists{
  my ($c,$component_name_field, $component_version_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('process_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::Process')->find($val, $data->{$component_name_field}, $data->{$component_version_field});
    return $exists ? 1:0;
  }

}


sub not_process_exists{
  my ($c,$component_name_field, $component_version_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_process_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::Process')->find($val, $data->{$component_name_field}, $data->{$component_version_field});
    return $exists ? 0:1;
  }

}



=head2 (not_)datatype_exists

  Returns true if the datatype named in the field exists.

=cut

sub datatype_exists{
    my ($c) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('datatype_exists');
    my $val = $dfv->get_current_constraint_value();
    my $exists = $c->model('ROMEDB::Datatype')->find($val);
    return $exists ? 1:0;
  }

}


sub not_datatype_exists{
    my ($c) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_datatype_exists');
    my $val = $dfv->get_current_constraint_value();
    my $exists = $c->model('ROMEDB::Datatype')->find($val);
    return $exists ? 0:1;
  }

}



=head2 (not_)process_creates_exists

  Returns true if the process_creates entry exists in the database

  Requires parameters
    1: The catalyst context
    2: The name of the field containing the process name
    3: The name of the field containing the component name
    4: The name of the field containing the component version
    5: The name of the field containing the datatype name

=cut

sub process_creates_exists{
  my ($c,$process_name_field, $component_name_field, $component_version_field, $datatype_name_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('process_creates_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::ProcessCreates')->find({
	name => $val,
	process_name => $data->{$process_name_field},
        process_component_name => $data->{$component_name_field},
        process_component_version => $data->{$component_version_field},
        datatype_name => $data->{$datatype_name_field},
	
							   });
    return $exists ? 1:0;
  }

}


sub not_process_creates_exists{
  my ($c,$process_name_field, $component_name_field, $component_version_field, $datatype_name_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_process_creates_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::ProcessCreates')->find({
	name => $val,
	process_name => $data->{$process_name_field},
        process_component_name => $data->{$component_name_field},
        process_component_version => $data->{$component_version_field},
        datatype_name => $data->{$datatype_name_field},
	
							   });
    return $exists ? 0:1;
  }

}





=head2 (not_)process_accepts_exists

  Returns true if the process_accepts entry exists in the database

  Requires parameters
    1: The catalyst context
    2: The name of the field containing the process name
    3: The name of the field containing the component name
    4: The name of the field containing the component version
    5: The name of the field containing the datatype name

=cut

sub process_accepts_exists{
  my ($c,$process_name_field, $component_name_field, $component_version_field, $datatype_name_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('process_accepts_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::ProcessAccepts')->find({
	name => $val,
	process_name => $data->{$process_name_field},
        process_component_name => $data->{$component_name_field},
        process_component_version => $data->{$component_version_field},
        datatype_name => $data->{$datatype_name_field}
							   });
    return $exists ? 1:0;
  }

}


sub not_process_accepts_exists{
  my ($c,$process_name_field, $component_name_field, $component_version_field, $datatype_name_field) = @_;

  return sub{
    my $dfv = shift;
    $dfv->name_this('not_process_accepts_exists');
    my $val = $dfv->get_current_constraint_value();
    my $data = $dfv->get_filtered_data;
    my $exists = $c->model('ROMEDB::ProcessAccepts')->find({
	name => $val,
	process_name => $data->{$process_name_field},
        process_component_name => $data->{$component_name_field},
        process_component_version => $data->{$component_version_field},
        datatype_name => $data->{$datatype_name_field},
							   });
    return $exists ? 0:1;
  }

}




=head2 is_version

  Returns true if the contents of this field look like a version number
  in the form major.minor.patch

=cut

sub is_version{

  return sub{
    my $dfv = shift;
    $dfv->name_this('is_version');
    my $val = $dfv->get_current_constraint_value();
    my $ok = $val =~/^\d+\.\d+\.\d+$/;
    return $ok ? 1:0;
  }

}


#for completeness, I can't actually envisage a use for this
sub is_not_version{

  return sub{
    my $dfv = shift;
    $dfv->name_this('is_not_version');
    my $val = $dfv->get_current_constraint_value();
    my $ok = $val =~/^\d+\.\d+\.\d+$/;
    return $ok ? 0:1
  }

}



=head2 (not_)parameter_exists

    call on the parameter name field
    expects:
    1: Cat context
    2: Name of the field containing the process name
    3: Name of the field containing the component name
    4: Name of the field containing the component version

=cut
sub parameter_exists{
    my ($c, $process_name_field, $component_name_field, $component_version_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('parameter_exists');
	my $val = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $process_name = $data->{$process_name_field};
	my $component_name = $data->{$component_name_field};
	my $component_version = $data->{$component_version_field};
	my $exists = $c->model('ROMEDB::Parameter')->find
	    ({
		name => $val,
		process_name => $process_name,
		process_component_name => $component_name,
		process_component_version => $component_version,

	     });
	    
	return $exists ? 1:0;
  }
}

sub not_parameter_exists{
    my ($c, $process_name_field, $component_name_field, $component_version_field) = @_;

    return sub{
	my $dfv = shift;
	$dfv->name_this('not_parameter_exists');
	my $val = $dfv->get_current_constraint_value();
	my $data = $dfv->get_filtered_data;
	my $process_name = $data->{$process_name_field};
	my $component_name = $data->{$component_name_field};
	my $component_version = $data->{$component_version_field};
	my $exists = $c->model('ROMEDB::Parameter')->find
	    ({
		name => $val,
		process_name => $process_name,
		process_component_name => $component_name,
		process_component_version => $component_version,

	     });
	    
	return $exists ? 0:1;
  }
}







=head2 (not_)job_exists

    call on the jid field
    expects parameters:
    1: Cat context

=cut
sub job_exists{
    my $c = shift;

    return sub{
	my $dfv = shift;
	$dfv->name_this('job_exists');
	my $val = $dfv->get_current_constraint_value();
	my $exists = $c->model('ROMEDB::Job')->find($val);
	return $exists ? 1:0;
  }
}

sub not_job_exists{
    my $c = shift;

    return sub{
	my $dfv = shift;
	$dfv->name_this('not_job_exists');
	my $val = $dfv->get_current_constraint_value();
	my $exists = $c->model('ROMEDB::Job')->find($val);
	return $exists ? 0:1;
  }
}




####
#This doesn't work. Get rid of it.

=head2

  AUTOLOAD forwards any method not_foo to the appropriate method foo
  with the inverse parameter set to 1.

=cut

sub AUTOLOAD{

  our $AUTOLOAD;

  if ($AUTOLOAD =~/^ROME::Constraints::not_(.+)$/){
    no strict;
    &$1(@_,1);
  }
}


1;
