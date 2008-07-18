package ROME::Controller::Devel;

use strict;
use warnings;
use base 'ROME::Controller::Base';
use ROME::Constraints;
use Template;
use File::Copy::Recursive qw/fmove fcopy dirmove/;
use File::Path qw/rmtree/;

=head1 NAME

ROME::Controller::Devel - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=over 2

=cut


=item components

  matches devel/components

  hands the new_component page template to the view.

=cut

sub components :Local{
    my ($self, $c) = @_;
    unless ($c->check_user_roles('dev')){
      $c->stash->{template} = 'site/messages';
      $c->stash->{error_msg} = 'Sorry, you do not have permission to view this page.';
      return;
    }

    #retrieve the selected component.
    if ($c->session->{component_name} && $c->session->{component_version}){
      $c->stash->{selected_component} =
	$c->model('ROMEDB::Component')->find
	  (
	   $c->session->{component_name},
	   $c->session->{component_version}
	  );
    }

    $c->stash->{template} = 'devel/create_component';
}


=item component_current

  Matches devel/component/current

  Ajax: returns the current component details

=cut
sub component_current :Path('component/current'){
  my ($self, $c) = @_;
  $c->stash->{template} = 'devel/current_component';
  $c->stash->{ajax} = 1;
  
  #retrieve the selected component.
  if ($c->session->{component_name} && $c->session->{component_version}){
    $c->stash->{selected_component} =
      $c->model('ROMEDB::Component')->find
	(
	 $c->session->{component_name},
	 $c->session->{component_version}
	);
  }
}




sub _validate_create_component :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(component_name component_version)],
		     optional => [qw(component_description)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'not_component_exists' => 'A component with that name and version already exists',
			       'is_version' => 'Does not look like a version number (major.minor.patch)'
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    component_name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::not_component_exists($c,'component_version'),
						    ],
					    component_version => [
							  ROME::Constraints::is_single,
								  ROME::Constraints::is_version,
								 ],
					    component_description =>[
								     ROME::Constraints::is_single,
								     ROME::Constraints::allowed_chars_plus
								    ],

					   },
		    };
 
 $c->form($dfv_profile);

}


=item create_component

  ajax method that takes the values from the
  new_component form and generates the new component.

  Matches devel/component/create

=cut
sub create_component :Path('component/create'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to create components';
    return;
  }
  
  my $comp;
  if ($c->forward('_validate_create_component')){

    #force the name to lower case
    $c->request->params->{component_name} = lc $c->request->params->{component_name};

    #find any components with the same name and set their
    #installed values to 0
    my @comps;
    if (@comps = $c->model('ROMEDB::Component')->search
      ({
	name => $c->request->params->{component_name}
       })){
      foreach $comp (@comps){
	$comp->installed(0);
	$comp->update;
      }
    }
    

    $comp = $c->model('ROMEDB::Component')->create
      ({
	name    => $c->request->params->{component_name},
	version => $c->request->params->{component_version},

	description => $c->request->params->{component_description},
	installed => 1,
       });
    unless ($comp){
      $c->stash->{error_msg} = 'Failed to create component';
      return;
    }
    

    #camel case the component name to the name of a controller
    my $cc_component_name = 
      join('', map{ ucfirst $_ } 
	   split(/_/, 
		 $c->request->params->{component_name}));

    #do we already have a component of that name? Database constraints
    #ensures the only difference is version, so package it up into
    #root/components: 
    my $version;
    if (-e  $c->path_to('lib','ROME','Controller',$cc_component_name.'.pm')){
      $version = $c->controller($cc_component_name)->VERSION;
      $c->forward('make_component_distribution');

      #and reset the template.
      $c->stash->{template} = 'site/messages';

    }

    #create a controller skeleton for this component
    my $config = {
		  INCLUDE_PATH => $c->path_to('components','templates'),
		  INTERPOLATE  => 1,
		  POST_CHOMP   => 1,
		  OUTPUT_PATH  => $c->path_to('lib','ROME','Controller'),
		 };
    my $template = Template->new($config);
    my $vars = {
		pkg_name => $cc_component_name,
		author   => $c->user->forename.' '.$c->user->surname,
		version  => $c->request->params->{component_version},
	       };
    $template->process('controller', $vars, $cc_component_name.'.pm')
      || die $template->error();


    #and a directory for views.
    my $dir = $c->path_to('root','src',$c->request->params->{component_name});

    #create new dir, overwriting old one if required
    rmtree( $dir, {} ) if (-e $dir);
    mkdir $dir;

    #and a directory for process templates
    $dir = $c->config->{process_templates}.'/'.$c->request->params->{component_name};

    #create new dir, overwriting old one if required
    rmtree( $dir, {} ) if (-e $dir);
    mkdir $dir; 

  }
  else{
    return;
  }

  $c->session->{component_name} = $comp->name;
  $c->session->{component_version} = $comp->version;
  $c->stash->{status_msg} = "Component created.";
  $c->stash->{error_msg} = 'RESTART YOUR SERVER, RELOAD THIS PAGE.';
}








sub _validate_select_component :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(component_name component_version)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'is_version' => 'Does not look like a version number (major.minor.patch)'
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    component_name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::component_exists($c,'component_version'),
						    ],
					    component_version => [
								  ROME::Constraints::is_single,
								  ROME::Constraints::is_version,
								 ],

					   },
		    };
 
 $c->form($dfv_profile);

}


=item select_component

  ajax method to select a component

  expects parameters component_name and component_version

  Matches devel/component/select

=cut
sub select_component :Path('component/select'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to select components';
    return;
  }
  
  my $comp;
  if ($c->forward('_validate_select_component')){

    $comp = $c->model('ROMEDB::Component')->find
      (
        $c->request->params->{component_name},
	$c->request->params->{component_version},
       );
    unless ($comp){
      $c->stash->{error_msg} = 'Failed to find component';
      return;
    }
  }
  else{
    return;
  }

  $c->session->{component_name} = $comp->name;
  $c->session->{component_version} = $comp->version;
  $c->stash->{status_msg} = "Component selected";
}










sub _validate_update_component :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(component_name component_version component_description)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'is_version' => 'Does not look like a version number (major.minor.patch)'
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    component_name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::component_exists($c,'component_version'),
						    ],
					    component_version => [
								  ROME::Constraints::is_single,
								  ROME::Constraints::is_version,
								 ],
					    component_description =>[
								     ROME::Constraints::is_single,
								     ROME::Constraints::allowed_chars_plus
								    ],

					   },
		    };
 
 $c->form($dfv_profile);

}


=item update_component

  ajax method
  
  required: component_name, component_version, component_description

  name and version are primary key and can't be changed.

  Matches devel/component/update

=cut
sub update_component :Path('component/update'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to update components';
    return;
  }
  
  my $comp;
  if ($c->forward('_validate_update_component')){

    $comp = $c->model('ROMEDB::Component')->find
      ({
	name    => $c->request->params->{component_name},
	version => $c->request->params->{component_version}
       });
    unless ($comp){
      $c->stash->{error_msg} = 'Component not found';
      return;
    }
  }
  else{
    return;
  }
  $comp->description($c->request->params->{component_description});
  $comp->update;

  $c->session->{component_name} = $comp->name;
  $c->session->{component_version} = $comp->version;
  $c->stash->{status_msg} = "Component updated";
}












=item component_autocomplete

  Matches devel/component/autocomplete

  Generates a list of component names to be formatted as
  a prototype.js autocompleter list

=cut
sub component_autocomplete :Path('component/autocomplete') {
  my ($self,$c) = @_;
  return unless $c->check_user_roles('dev');

  my $val = $c->request->params->{component_name};
  $val =~ s/\*/%/g;
  $c->stash->{ajax} = 1;

  my $components =  $c->model('ROMEDB::Component')->search_like({name=>'%'.$val.'%'});

  $c->stash->{template} = 'devel/component_autocomplete';
  $c->stash->{components} = $components;

}








sub _validate_create_process :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(process_name process_display_name process_component_name process_component_version)],
		     optional => [qw(process_description)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'not_process_exists' => 'A process with that name already exists',
			       'is_version' => 'Does not look like a version number (major.minor.patch)',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::not_process_exists($c,'process_component_name','process_component_version'),
							    ],
					    process_component_name => [
								       ROME::Constraints::is_single,
								       ROME::Constraints::allowed_chars,
								       ROME::Constraints::component_exists($c,'process_component_version')
								      ],
					    process_component_version => [
									  ROME::Constraints::is_single,
									  ROME::Constraints::is_version,
									 ],
					    process_display_name =>[
								    ROME::Constraints::is_single,
								    ROME::Constraints::allowed_chars,
								   ],
					    process_description =>[
								   ROME::Constraints::is_single,
								   ROME::Constraints::allowed_chars_plus
								  ],
					    
					   },
		    };
 
 $c->form($dfv_profile);

}


=item create_process

  ajax method to generate a new process

  Matches devel/process/create

=cut
sub create_process :Path('process/create'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to create new processes';
    return;
  }

  $c->request->params->{process_display_name} = $c->request->params->{process_name} unless $c->request->params->{process_display_name};

  if ($c->forward('_validate_create_process')){

    my $process = $c->model('ROMEDB::Process')->create
      ({
	name    => $c->request->params->{process_name},
	component_name => $c->request->params->{process_component_name},
	component_version => $c->request->params->{process_component_version},
	description => $c->request->params->{process_description},
	display_name => $c->request->params->{process_display_name} ,
	processor => 'R',
       });

    unless ($process){
      $c->stash->{error_msg} = 'Failed to create process';
      return;
    }


    #Create the process page template file
    my $template_file = $c->path_to('root','src',$process->component_name,$process->name).'';

    my $config = {
		  INCLUDE_PATH => $c->path_to('components','templates'),
		  INTERPOLATE  => 1,
		  POST_CHOMP   => 1,
		  START_TAG    => '{%',
		  END_TAG      => '%}',
		 };
    my $template = Template->new($config);
    my $vars = {
		process_display_name => $process->display_name,
		process_name => $process->name,
		component_name => $process->component_name,
		component_version => $process->component_version,
	       };

    $template->process('process_template', $vars, $template_file)
      || die $template->error();



    #add the process actions to the controller
    #CamelCase the component name.
    my $cc_component_name = 
      join('', map{ ucfirst $_ } 
	   split(/_/, 
		 $c->request->params->{process_component_name}));
 

    #parse the process_action template file into a string.
    $config = {
		  INCLUDE_PATH => $c->path_to('components','templates'),
		  INTERPOLATE  => 1,
		  POST_CHOMP   => 1,
		 };
    $template = Template->new($config);
    $vars = {
	     process_name => $process->name ,
	     process_display_name => $process->display_name,
	     component_name => $process->component_name,
	     component_version => $process->component_version,
	    };
    my $process_action;
    $template->process('process_action', $vars, \$process_action)
      || die $template->error();

    #and insert it into the controller, saving the previous version in component_name.pm.bak
    my $component_file = $c->path_to('lib','ROME','Controller', $cc_component_name.'.pm');
    warn $component_file;
    {
      local $^I = '.bak';
      local @ARGV = ($component_file);
      while (<>){
	s/(### PROCESS METHODS ###)/$1\n\n$process_action\n\n/;
	print;
      }
    }

  }
  else{
    return;
  }

  $c->stash->{status_msg} = "Process created";
  $c->stash->{error_msg} = "RESTART SERVER AND RELOAD THIS PAGE!";
}






sub _validate_delete_process :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(process_name process_component_name process_component_version)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'process_exists' => 'Process not found',
			       'is_version' => 'Does not look like a version number (major.minor.patch)',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c,'process_component_name','process_component_version'),
							    ],
					    process_component_name => [
								       ROME::Constraints::is_single,
								       ROME::Constraints::allowed_chars,
								       ROME::Constraints::component_exists($c,'process_component_version')
								      ],
					    process_component_version => [
									  ROME::Constraints::is_single,
									  ROME::Constraints::is_version,
									 ],
					   },
		    };
 
 $c->form($dfv_profile);

}


=item delete_process

  ajax method to generate a new process

  Matches devel/process/delete

  params are process_name, component_name, component_version.
  The latter two default to the currently selected component

=cut
sub delete_process :Path('process/delete'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to delete processes';
    return;
  }

  $c->request->params->{process_component_name} = $c->session->{component_name}  
    if ( !$c->request->params->{process_component_name} && $c->session->{component_name} );
  $c->request->params->{process_component_version} = $c->session->{component_version}  
    if ( !$c->request->params->{process_component_version} && $c->session->{component_version} );

  my $process;
  if ($c->forward('_validate_delete_process')){

    $process = $c->model('ROMEDB::Process')->find
      ({
	name    => $c->request->params->{process_name},
	component_name => $c->request->params->{process_component_name},
	component_version => $c->request->params->{process_component_version},
       });
    unless ($process){
      $c->stash->{error_msg} = 'Failed to delete process';
      return;

    }

    #remove the process page template file 
    my $template_file = $c->path_to('root','src',$process->component_name,$process->name).'';
    unlink ($template_file) or warn "Failed to delete file $template_file"; 
    
    #remove the bits of the process from the Controller.
    #CamelCase the component name.
    my $cc_component_name = 
      join('', map{ ucfirst $_ } 
	   split(/_/, 
		 $process->component_name));
 
    #and insert it into the controller, saving the previous version in component_name.pm.bak
    my $component_file = $c->path_to('lib','ROME','Controller', $cc_component_name.'.pm');
    warn $component_file;
    {
      local $^I = '.bak';
      local @ARGV = ($component_file);

      my $process_name = $process->name;
      while (<>) {
	print /### START PROCESS $process_name/ .. /### END PROCESS $process_name/ ?'':$_;
      } 


    }


  }
  else{
    return;
  }
  $process->delete;
  $c->stash->{status_msg} = "Process deleted";
}






=item process_form

  Matches devel/process/form

=cut
sub process_form :Path('process/form'){
  my ($self,$c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'devel/new_process';
  if ($c->session->{component_name} && $c->session->{component_version}){
    my $comp= $c->model('ROMEDB::Component')->find
      (
       $c->session->{component_name},
       $c->session->{component_version}
      );
    $c->stash->{selected_component} = $comp;
  }
}




sub _validate_process_accepts_form :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     optional => [qw(process_name process_component_name process_component_version)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'process_exists' => 'Process not found',
			       'is_version' => 'Does not look like a version number (major.minor.patch)',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c,'process_component_name','process_component_version'),
							    ],
					    process_component_name => [
								       ROME::Constraints::is_single,
								       ROME::Constraints::allowed_chars,
								       ROME::Constraints::component_exists($c,'process_component_version')
								      ],
					    process_component_version => [
									  ROME::Constraints::is_single,
									  ROME::Constraints::is_version,
									 ],
					   },
		    };
 
 $c->form($dfv_profile);

}




=item process_accepts_form

  Matches devel/process/accepts_form

  takes parameter process_name
  and component_name, component_version though these
  default to the value of the currently selected component.

=cut

sub process_accepts_form :Path('process/accepts_form'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';

  #default to the currently selected component
  $c->request->params->{process_component_name} = $c->session->{component_name}
      if(!$c->request->params->{process_component_name} && $c->session->{component_name});
 
  $c->request->params->{process_component_version} = $c->session->{component_version}
      if(!$c->request->params->{process_component_version} && $c->session->{component_version});
  
  
  if ($c->forward('_validate_process_accepts_form')){

    if ($c->request->params->{process_name} 
	&& $c->request->params->{process_component_name}
	&& $c->request->params->{process_component_version})
      {
	my $proc = $c->model('ROMEDB::Process')->find
	  ({
	    name => $c->request->params->{process_name},
	    component_name => $c->request->params->{process_component_name},
	    component_version => $c->request->params->{process_component_version}
	   });
	$c->stash->{process} = $proc;
      }
    $c->stash->{template} = 'devel/new_process_accepts';
  }
  else{
    return;
  }
}





=item process_creates_form

  Matches devel/process/creates_form

  takes parameter process_name
  and component_name, component_version though these
  default to the value of the currently selected component.

=cut

sub process_creates_form :Path('process/creates_form'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';

  #default to the currently selected component
  $c->request->params->{process_component_name} = $c->session->{component_name}
      if(!$c->request->params->{process_component_name} && $c->session->{component_name});
 
  $c->request->params->{process_component_version} = $c->session->{component_version}
      if(!$c->request->params->{process_component_version} && $c->session->{component_version});
  
  #just use the same validation as for accepts form  
  if ($c->forward('_validate_process_accepts_form')){

    if ($c->request->params->{process_name} 
	&& $c->request->params->{process_component_name}
	&& $c->request->params->{process_component_version})
      {
	my $proc = $c->model('ROMEDB::Process')->find
	  ({
	    name => $c->request->params->{process_name},
	    component_name => $c->request->params->{process_component_name},
	    component_version => $c->request->params->{process_component_version}
	   });
	$c->stash->{process} = $proc;
      }
    $c->stash->{template} = 'devel/new_process_creates';
  }
  else{
    return;
  }
}




=item process_autocomplete

  Matches devel/process/autocomplete

  Generates a list of process names to be formatted as
  a prototype.js autocompleter list

=cut
sub process_autocomplete :Path('process/autocomplete') {
  my ($self,$c) = @_;
  return unless $c->check_user_roles('dev');

  my $val = $c->request->params->{process_name};
  $val =~ s/\*/%/g;
  $c->stash->{ajax} = 1;

  my $processes =  $c->model('ROMEDB::Process')->search_like({name=>'%'.$val.'%'});

  $c->stash->{template} = 'devel/process_autocomplete';
  $c->stash->{processes} = $processes;

}








sub _validate_process_accepts_create :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     optional => [qw(name process_name process_component_name process_component_version datatype_name)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'process_exists' => 'Process not found',
			       'is_version' => 'Does not look like a version number (major.minor.patch)',
			       'datatype_exists' => 'Datatype not found',
			       'not_process_accepts_exists' => 'There is already a file of that name and datatype for this process',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c,'process_component_name','process_component_version'),
							    ],
					    process_component_name => [
								       ROME::Constraints::is_single,
								       ROME::Constraints::allowed_chars,
								       ROME::Constraints::component_exists($c,'process_component_version')
								      ],
					    process_component_version => [
									  ROME::Constraints::is_single,
									  ROME::Constraints::is_version,
									 ],
					    datatype_name => [
							      ROME::Constraints::is_single,
							      ROME::Constraints::datatype_exists($c),
							     ],
					    name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::not_process_accepts_exists($c, 'process_name','process_component_name', 'process_component_version', 'datatype_name')
						    ],
					    
					   },
		    };
 
 $c->form($dfv_profile);

}




=item process_accepts_create

  Matches devel/process/add_accepts

  takes parameters name, process_name, datatype_name
  and process_component_name, process_component_version though these
  default to the value of the currently selected component.

=cut

sub process_accepts_create :Path('process/add_accepts'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';

  #default to the currently selected component
  $c->request->params->{process_component_name} = $c->session->{component_name}
      if(!$c->request->params->{process_component_name} && $c->session->{component_name});
 
  $c->request->params->{process_component_version} = $c->session->{component_version}
      if(!$c->request->params->{process_component_version} && $c->session->{component_version});

  if ($c->forward('_validate_process_accepts_create')){
    my $proc_acc = $c->model('ROMEDB::ProcessAccepts')->create
      ({
	name => $c->request->params->{name},
	process_name => $c->request->params->{process_name},
	process_component_name => $c->request->params->{process_component_name},
	process_component_version => $c->request->params->{process_component_version},
	datatype_name => $c->request->params->{datatype_name},
       });
    $c->stash->{status_msg} = 'added accepted datatype';
  }
  else{
    return;
  }
}







sub _validate_process_creates_create :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     optional => [qw(name process_name process_component_name process_component_version datatype_name suffix is_image is_export is_report)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'process_exists' => 'Process not found',
			       'is_version' => 'Does not look like a version number (major.minor.patch)',
			       'datatype_exists' => 'Datatype not found',
			       'not_process_creates_exists' => 'There is already a file of that name and datatype for this process',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c,'process_component_name','process_component_version'),
							    ],
					    process_component_name => [
								       ROME::Constraints::is_single,
								       ROME::Constraints::allowed_chars,
								       ROME::Constraints::component_exists($c,'process_component_version')
								      ],
					    process_component_version => [
									  ROME::Constraints::is_single,
									  ROME::Constraints::is_version,
									 ],
					    datatype_name => [
							      ROME::Constraints::is_single,
							      ROME::Constraints::datatype_exists($c),
							     ],
					    name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::not_process_creates_exists($c, 'process_name','process_component_name', 'process_component_version', 'datatype_name')
						    ],
					    suffix => [
						       ROME::Constraints::is_single,
						       ROME::Constraints::allowed_chars,
						      ],
					    is_image =>[
							ROME::Constraints::is_single,
						       ],
					    is_export=>[
							ROME::Constraints::is_single,
						       ],
					    is_report=>[
							ROME::Constraints::is_single,
						       ],
					    
					   },
		    };
 
 $c->form($dfv_profile);

}




=item process_creates_create

  Matches devel/process/add_creates

  takes parameters name, process_name, datatype_name
  and process_component_name, process_component_version though these
  default to the value of the currently selected component.

=cut

sub process_creates_create :Path('process/add_creates'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';

  #default to the currently selected component
  $c->request->params->{process_component_name} = $c->session->{component_name}
      if(!$c->request->params->{process_component_name} && $c->session->{component_name});
 
  $c->request->params->{process_component_version} = $c->session->{component_version}
      if(!$c->request->params->{process_component_version} && $c->session->{component_version});

  if ($c->forward('_validate_process_creates_create')){
    my $proc_create = $c->model('ROMEDB::ProcessCreates')->create
      ({
	name => $c->request->params->{name},
	process_name => $c->request->params->{process_name},
	process_component_name => $c->request->params->{process_component_name},
	process_component_version => $c->request->params->{process_component_version},
	datatype_name => $c->request->params->{datatype_name},
	suffix => $c->request->params->{suffix},
      });

    $proc_create->is_image(1) if $c->request->params->{is_image} eq 'on';
    $proc_create->is_export(1) if $c->request->params->{is_export} eq 'on';
    $proc_create->is_report(1) if $c->request->params->{is_report} eq 'on';
    $proc_create->update;
    $c->stash->{status_msg} = 'added created datatype';
  }
  else{
    return;
  }
}




















sub _validate_process_creates_delete :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(process_component_name process_component_version process_name datatype_name name)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'process_exists' => 'A process with that name already exists',
			       'is_version' => 'Does not look like a version number (major.minor.patch)',
			       'process_creates_exists' => 'Process does not create that datafile'
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_component_name => [
							       ROME::Constraints::is_single,
							       ROME::Constraints::allowed_chars,
							       ROME::Constraints::component_exists($c,'process_component_version')
							      ],
					    process_component_version => [
								  ROME::Constraints::is_single,
								  ROME::Constraints::is_version,
								 ],
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c,'process_component_name','process_component_version'),
							    ],
					    datatype_name => [
							      ROME::Constraints::is_single,
							      ROME::Constraints::allowed_chars,
							      ROME::Constraints::datatype_exists($c),
							     ],
					    
					    name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::process_creates_exists($c, 'process_name','process_component_name', 'process_component_version', 'datatype_name')
						    ],
					   },
		    };
 
 $c->form($dfv_profile);

}


=item process_creates_delete

  ajax method to generate a new process

  Matches devel/process/delete_creates

  Parameters
  name: Name of the process_creates file (not the filename, the
        placeholder name used in the template)
  process_component_name: the name of the component to which this process belongs
  process_component_version: and its version number 
  process_name: the name of the process we are deleting the relationship for
  datatype_name: the datatype of the file in the relationship

=cut
sub process_creates_delete :Path('process/delete_creates'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to delete created datatypes from processes';
    return;
  }

  my $pc;
  if ($c->forward('_validate_process_creates_delete')){

    $pc = $c->model('ROMEDB::ProcessCreates')->find
      ({
	name    => $c->request->params->{name},
	process_component_name => $c->request->params->{process_component_name},
	process_component_version => $c->request->params->{process_component_version},
	process_name => $c->request->params->{process_name},
	datatype_name => $c->request->params->{datatype_name},
       });
    unless ($pc){
      $c->stash->{error_msg} = 'Failed to retrieve process_creates relationship from database';
      return;
    }
  }
  else{
    return;
  }
  
  $pc->delete;
  $c->stash->{status_msg} = "Process creates relationship deleted";
}









sub _validate_process_accepts_delete :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(process_component_name process_component_version process_name datatype_name name)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'process_exists' => 'A process with that name already exists',
			       'is_version' => 'Does not look like a version number (major.minor.patch)',
			       'process_creates_exists' => 'Process does not create that datafile'
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_component_name => [
							       ROME::Constraints::is_single,
							       ROME::Constraints::allowed_chars,
							       ROME::Constraints::component_exists($c,'process_component_version')
							      ],
					    process_component_version => [
								  ROME::Constraints::is_single,
								  ROME::Constraints::is_version,
								 ],
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c,'process_component_name','process_component_version'),
							    ],
					    datatype_name => [
							      ROME::Constraints::is_single,
							      ROME::Constraints::allowed_chars,
							      ROME::Constraints::datatype_exists($c),
							     ],
					    
					    name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::process_accepts_exists($c, 'process_name','process_component_name', 'process_component_version', 'datatype_name')
						    ],
					   },
		    };
 
 $c->form($dfv_profile);

}


=item process_accepts_delete

  ajax method to generate a new process

  Matches devel/process/delete_accepts

  Parameters
  name: Name of the process_accepts file (not the filename, the
        placeholder name used in the template)
  process_component_name: the name of the component to which this process belongs
  process_component_version: and its version number 
  process_name: the name of the process we are deleting the relationship for
  datatype_name: the datatype of the file in the relationship

=cut
sub process_accepts_delete :Path('process/delete_accepts'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to delete created datatypes from processes';
    return;
  }

  my $pc;
  if ($c->forward('_validate_process_accepts_delete')){

    $pc = $c->model('ROMEDB::ProcessAccepts')->find
      ({
	name    => $c->request->params->{name},
	process_component_name => $c->request->params->{process_component_name},
	process_component_version => $c->request->params->{process_component_version},
	process_name => $c->request->params->{process_name},
	datatype_name => $c->request->params->{datatype_name},
       });
    unless ($pc){
      $c->stash->{error_msg} = 'Failed to retrieve process_accepts relationship from database';
      return;
    }
  }
  else{
    return;
  }
  
  $pc->delete;
  $c->stash->{status_msg} = "Process accepts relationship deleted";
}











=item datatype_autocomplete

  Matches devel/datatype/autocomplete

  Generates a list of datatype names to be formatted as
  a prototype.js autocompleter list

=cut
sub datatype_autocomplete :Path('datatype/autocomplete') {
  my ($self,$c) = @_;
  return unless $c->check_user_roles('dev');

  my $val = $c->request->params->{datatype_name};
  $val =~ s/\*/%/g;
  $c->stash->{ajax} = 1;

  my $datatypes =  $c->model('ROMEDB::Datatype')->search_like({name=>'%'.$val.'%'});

  $c->stash->{template} = 'devel/datatype_autocomplete';
  $c->stash->{datatypes} = $datatypes;

}



=item datatype_description_autocomplete

  Matches devel/datatype/description_autocomplete

  Generates a list of datatype descriptions to be formatted as
  a prototype.js autocompleter list

=cut
sub datatype_description_autocomplete :Path('datatype/description_autocomplete') {
  my ($self,$c) = @_;
  return unless $c->check_user_roles('dev');

  my $val = $c->request->params->{description};
  $val =~ s/\*/%/g;
  $c->stash->{ajax} = 1;

  my $datatypes =  $c->model('ROMEDB::Datatype')->search_like({description=>'%'.$val.'%'});

  $c->stash->{template} = 'devel/datatype_description_autocomplete';
  $c->stash->{datatypes} = $datatypes;

}







=item make_component_distribution

  matches devel/component/distribution

  hands the make_component_distribution page template
  to the view

=cut

sub make_component_distribution :Local{
    my ($self, $c) = @_;

    unless ($c->check_user_roles('dev')){
      $c->stash->{template} = 'site/messages';
      $c->stash->{error_msg} = "You don't have permission to make component distributions";
      return;
    }

    #this needs to take param component_name and generate a distribution
    #of the currently installed version of that component.
    
    #then stick that distribution in the root/components dir.
    $c->stash->{template} = 'devel/make_component_distribution';
    return;
}



#sub _make_component_distribution :Private{
#  my ($self,$c) = @_;
#  
#}

=item datatypes

  matches devel/datatypes
  passes the datatype page template to the view

=cut
sub datatypes :Local{
  my ($self,$c) = @_;
  unless ($c->check_user_roles('dev')){
    $c->stash->{template} = 'site/messages';
    $c->stash->{error_msg} = "You don't have permission to manage datatypes";
    return;
  }
  if ($c->session->{datatype_name}){
    $c->stash->{datatype} = $c->model('ROMEDB::Datatype')->find($c->session->{datatype_name});
  }
  $c->stash->{template} = 'devel/datatypes';
}


=item current_datatype

  matches devel/datatype/current

  ajax. forwards the current datatype template to the view

=cut
sub current_datatype :Path('datatype/current'){
   my ($self,$c) = @_;

   $c->stash->{ajax} = 1;

   unless ($c->check_user_roles('dev')){
     $c->stash->{template} = 'site/messages';
     $c->stash->{error_msg} = "You don't have permission to view current datatypes";
     return;
   }

   if ($c->session->{datatype_name}){
     $c->stash->{datatype} = $c->model('ROMEDB::Datatype')->find($c->session->{datatype_name});
   }

   $c->stash->{template} = 'devel/current_datatype'; 

}






sub _validate_datatype_create :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(name)],
		     optional => [qw(description default_blurb)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'not_datatype_exists' => 'A datatype of that name already exists',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::not_datatype_exists($c),
						    ],
					    description => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars_plus,
								 ],
					   },
		    };
 
 $c->form($dfv_profile);

}


=item datatype_create

  ajax method to create a new datatype

  Matches devel/datatype/create

  Parameters
  name : name of the datatype. Must be unique
  description: Optional brief description of the datatype
  default_blurb: Optional longer description of the datatype for use in report files.

=cut
sub datatype_create :Path('datatype/create'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to create datatypes';
    return;
  }

  my $datatype;
  if ($c->forward('_validate_datatype_create')){

    $datatype = $c->model('ROMEDB::Datatype')->create
      ({
	name    => $c->request->params->{name},
	description => $c->request->params->{description},
	default_blurb => $c->request->params->{default_blurb} || $c->request->params->{description},
       });
    unless ($datatype){
      $c->stash->{error_msg} = 'Failed to create datatype';
      return;
    }
  }
  else{
    return;
  }
 
  $c->session->{datatype_name} = $datatype->name;
  $c->stash->{status_msg} = "Created datatype ".$datatype->name;
}





sub _validate_datatype_delete :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(name)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'datatype_exists' => 'Datatype not found',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::datatype_exists($c),
						    ],
					   },
		    };
 
 $c->form($dfv_profile);

}


=item datatype_delete

  ajax method to delete a datatype

  Matches devel/datatype/delete

  Parameters
  name : name of the datatype.

=cut
sub datatype_delete :Path('datatype/delete'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to delete datatypes';
    return;
  }

  if ($c->forward('_validate_datatype_delete')){

    my $datatype = $c->model('ROMEDB::Datatype')->find($c->request->params->{name});
    unless ($datatype){
      $c->stash->{error_msg} = 'Failed to delete datatype';
      return;
    }
    $datatype->delete;
  }
  else{
    return;
  }
  
  
  $c->stash->{status_msg} = 'Deleted datatype';
}




sub _validate_datatype_update :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(name)],
		     optional => [qw(description default_blurb)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'datatype_exists' => 'Datatype not found',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::datatype_exists($c),
						    ],
					    description => [
							    ROME::Constraints::is_single,
							    ROME::Constraints::allowed_chars_plus,
							   ],
					    default_blurb => [
							      ROME::Constraints::is_single,
							      ROME::Constraints::allowed_chars_plus,
							     ],
					   },
		    };
 
 $c->form($dfv_profile);

}


=item datatype_update

  ajax method to update a datatype details

  Matches devel/datatype/update

  Parameters
  name : name of the datatype (PK, can't be altered)
  description: Optional brief description of the datatype
  default_blurb: Optional longer description of the datatype for use in report files.

=cut
sub datatype_update :Path('datatype/update'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to update datatypes';
    return;
  }

  if ($c->forward('_validate_datatype_update')){

    my $datatype = $c->model('ROMEDB::Datatype')->find($c->request->params->{name});

    unless ($datatype){
      $c->stash->{error_msg} = 'Failed to update datatype';
      return;
    }

    $datatype->description($c->request->params->{description});
    $datatype->default_blurb($c->request->params->{default_blurb} || $c->request->params->{description});
    $datatype->update;
  }
  else{
    return;
  }
 
  $c->stash->{status_msg} = "Updated datatype";
}






sub _validate_datatype_select :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(name)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'datatype_exists' => 'Datatype not found',
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    name => [
						     ROME::Constraints::is_single,
						     ROME::Constraints::allowed_chars,
						     ROME::Constraints::datatype_exists($c),
						    ],
					   },
		    };
 
 $c->form($dfv_profile);

}


=item datatype_select

  ajax method to select a datafile 

  Matches devel/datatype/select

  Parameters
  name : name of the datatype

=cut
sub datatype_select :Path('datatype/select'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to select datatypes';
    return;
  }

  if ($c->forward('_validate_datatype_select')){

    my $datatype = $c->model('ROMEDB::Datatype')->find($c->request->params->{name});

    unless ($datatype){
      $c->stash->{error_msg} = 'Failed to select datatype';
      return;
    }
    $c->session->{datatype_name} = $datatype->name;
  }
  else{
    return;
  }
 
  $c->stash->{status_msg} = "Selected datatype";
}





sub _validate_process_param_form :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(process_name process_component_name process_component_version)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'process_exists' => 'Process not found',
			       'is_version' => "Doesn't look like a version number (major.minor.patch)",
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c, 'process_component_name', 'process_component_version'),
						    ],
					    process_component_name => [
									ROME::Constraints::is_single,
									ROME::Constraints::allowed_chars,
								       ],
					    process_component_version => [
									  ROME::Constraints::is_single,
									  ROME::Constraints::is_version,
									 ]
					   },
		    };
 
 $c->form($dfv_profile);

}

=item process_param_form

  Matches /devel/process/parameters_form

  Ajax. Passees the process_param_form template
  to the view

=cut
sub process_param_form :Path('process/parameters_form'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';
  
  #check permissions
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to create new parameters';
    return;
  }

  #set selected component name as default
  $c->request->params->{process_component_name} = $c->request->params->{process_component_name} || $c->session->{component_name};
  $c->request->params->{process_component_version} = $c->request->params->{process_component_version} || $c->session->{component_version};

  #check constraints
  if ($c->forward('_validate_process_param_form')){

    # find the process to which we're adding
    my $process= $c->model('ROMEDB::Process')->find
      ({
       name              => $c->request->params->{process_name},
       component_name    => $c->request->params->{process_component_name},
       component_version => $c->request->params->{process_component_version},
      });

    $c->stash->{selected_process} = $process;

    $c->stash->{template} = 'devel/process_param_form';
  }
  else{
    return;
  }
  
}



sub _validate_process_param_create :Local{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(process_name process_component_name process_component_version parameter_name form_element_type)],
		     optional => [qw(parameter_display_name parameter_description parameter_optional form_element_values element_value_is element_value_numtype element_value_min element_value_max element_is_multiple)],
		     dependencies=>{
				    'element_value_is' => {'numeric' => [qw(element_value_numtype)]},
				    'form_element_type' => {
							    'text' => ['element_value_is'],
							    'textarea' => ['element_value_is'],
							    'radio' => ['form_element_values'],
							    'select' => ['form_element_values'],
							    'checkbox_group' => ['form_element_values'],
							   }
				   },
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'allowed_chars_plus' => 'Please use only letters, numbers, commas, full stops and spaces in this field',
			       'is_single' => 'Cannot take multiple values',
			       'component_exists' => 'Component not found',
			       'process_exists' => 'Process not found',
			       'is_version' => "Doesn't look like a version number (major.minor.patch)",
			       'not_parameter_exists' => 'Process already has a parameter of that name', 
			       'is_boolean' => 'Value can be only 1 (is optional) or 0 (is not optional, default)',
			       'valid_type' => 'Not a valid element type',
			       'valid_element_values' => 'Invalid element values, values can be made up of letters, numbers and underscores. no spaces are allowed. They should be separated with commas and can optionally be grouped with slashes, eg: blue1, blue2 / red1, red2 / yellow ',
			       'valid_value_type' => 'value type can only be text or numeric',
			       'valid_value_numtype' => 'value number type can only be int or real',
			       'valid_min' => 'Not a valid value for minimum',
			       'valid_max' => 'Not a valid value for maximum',
			       'min_less_max' => 'Minimum must be less than maximum',
			       'is_checkbox_value' => 'Checkbox value can only be on or off',
			      },
 			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,
		     constraint_methods => {
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c, 'process_component_name', 'process_component_version'),
						    ],
					    process_component_name => [
									ROME::Constraints::is_single,
									ROME::Constraints::allowed_chars,
								       ROME::Constraints::component_exists($c, 'process_component_version'),
								       ],
					    process_component_version => [
									  ROME::Constraints::is_single,
									  ROME::Constraints::is_version,
									 ],
					    parameter_name => [
							       ROME::Constraints::is_single,
							       ROME::Constraints::allowed_chars,
							       ROME::Constraints::not_parameter_exists($c, 'process_name', 'process_component_name', 'process_component_version'),
							      ],
					    parameter_display_name => [
								       ROME::Constraints::is_single,
								       ROME::Constraints::allowed_chars_plus,
								      ],
					    parameter_description => [
								      ROME::Constraints::is_single,
								      ROME::Constraints::allowed_chars_plus,
								     ],
					    parameter_optional => [
								   ROME::Constraints::is_single,
								   ROME::Constraints::is_boolean,
								  ],

					    form_element_type =>[
								 ROME::Constraints::is_single,
								 sub { 
								   my ($dfv, $val) = @_;
								   $dfv->set_current_constraint_name('valid_type');
								   return 1 if ($val eq 'text' 
										|| $val eq 'textarea'
										|| $val eq 'checkbox' 
										|| $val eq 'checkbox_group'
									        || $val eq 'radio'
									        || $val eq 'select');
								   return;
								 }, 
								],
					    form_element_values => [
								    ROME::Constraints::is_single,
								    sub { 
								      my ($dfv, $val) = @_;
								      $dfv->set_current_constraint_name('valid_element_values');
								      my $valid = 1;
								      my @vals = split '/', $val;
								      foreach (@vals){
									$valid=0 unless /^(\s*\w+,?\s*)+$/;
								      }
								      return $valid;
								    }, 
								   ],
					    element_is_multiple => [
								    ROME::Constraints::is_single,
								    ROME::Constraints::is_boolean,
								   ],
					    element_value_is => [
								 ROME::Constraints::is_single,
								 sub { 
								   my ($dfv, $val) = @_;
								   $dfv->set_current_constraint_name('valid_value_type');
								   return 1 if ($val eq 'numeric' 
										|| $val eq 'text');
								   return;
								 }, 
								],
					    element_value_numtype => [
								      ROME::Constraints::is_single,
								      sub { 
									my ($dfv, $val) = @_;
									$dfv->set_current_constraint_name('valid_value_numtype');
									return 1 if ($val eq 'int' 
										     || $val eq 'real');
									return;
								 }, 								      
								     ],
					    element_value_min => [
								  ROME::Constraints::is_single,
								  sub{
								    my $dfv = shift;
								    $dfv->name_this('valid_min');
								    my $val = $dfv->get_current_constraint_value();
								    my $numtype = $dfv->get_filtered_data->{element_value_numtype};
								    if ($numtype eq 'int'){
								      return 1 if $val =~/^\d+$/;
								    }
								    if ($numtype eq 'real'){
								      return 1 if $val =~/^\d+(\.\d+)?$/;
								    }
								    return;
								  },
								  sub{
								    my $dfv = shift;
								    $dfv->name_this('min_less_max');
								    my $val = $dfv->get_current_constraint_value();
								    my $max = $dfv->get_filtered_data->{element_value_max};
								    return 1 unless $max;
								    return 1 if $val < $max;
								    return;
								  },
								  
								 ],
					    element_value_max => [
								  ROME::Constraints::is_single,
								  sub{
								    my $dfv = shift;
								    $dfv->name_this('valid_max');
								    my $val = $dfv->get_current_constraint_value();
								    my $numtype = $dfv->get_filtered_data->{element_value_numtype};
								    if ($numtype eq 'int'){
								      return 1 if $val =~/^\d+$/;
								    }
								    if ($numtype eq 'real'){
								      return 1 if $val =~/^\d+(\.\d+)?$/;
								    }
								    return;
								  },
								  
								 ],
					    
					   }, #end msgs
		    };
 
 $c->form($dfv_profile);

}

=item process_param_create

  Matches /devel/process/parameter/create

  Ajax. Creates a parameter for a process


  Parameters:

  process_name 
     Name of the process to which the parameter is to be added
  process_component_name
     Name of the component to which that process belongs
  process_component_version
     Version of the component to which that process belongs
  parameter_name
     Name of the parameter (a database key, no spaces)
  parameter_display_name
     Optional display name for the parameter (defaults to parameter_name 
     if not specified)
  parameter_description
     Optional (but advisable) description of the parameter
  parameter_optional: 
     Optional boolean value determining whether this parameter is 
     optional (1) or not (0). Defaults to 0 if unspecified 
     (ie. process parameters are required by default)


=cut
sub process_param_create :Path('process/parameter/create'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';
  
  #check permissions
  unless ($c->check_user_roles('dev')){
    $c->stash->{error_msg} = 'Sorry, you do not have permission to create new parameters';
    return;
  }


  #check constraints
  if ($c->forward('_validate_process_param_create')){

    #add the parameter to the database:
    #note that we can't define a default value for the parameter
    #at creation because it needs to be checked against the parameter constraints
    #which aren't yet defined.
    my $param = $c->model('ROMEDB::Parameter')->create
      ({
	name => $c->request->params->{parameter_name},
	display_name => $c->request->params->{parameter_display_name} || $c->request->params->{parameter_name},
	process_name => $c->request->params->{process_name},
	process_component_name => $c->request->params->{process_component_name},
	process_component_version => $c->request->params->{process_component_version},
	description => $c->request->params->{parameter_description} || '',
	optional   => $c->request->params->{parameter_optional} || '',
	form_element_type => $c->request->params->{form_element_type},
	min_value => $c->request->params->{element_value_min},
	max_value => $c->request->params->{element_value_max}
       });
 

    #add the process parameter checks to the controller
    #CamelCase the component name.
    my $cc_component_name = 
      join('', map{ ucfirst $_ } 
	   split(/_/, 
		 $param->process_component_name));
 
    #insert constraints into the controller, saving the previous version in component_name.pm.bak
    my $component_file = $c->path_to('lib','ROME','Controller', $cc_component_name.'.pm');
    {
      local $^I = '.bak';
      local @ARGV = ($component_file);

      # generate constraint_methods strings appropriate to
      # this parameter:

      my @constraints;
      if ($c->request->params->{form_element_type} =~/^text/){
	
	#add the allowed_chars constraint
	push @constraints, 'ROME::Constraints::allowed_chars_plus';
	
	if (my $numtype = $c->request->params->{element_value_numtype}){
	  
	  if($numtype eq 'int'){
	    push @constraints, 'ROME::Constraints::is_integer';
	  }
	  else{
	    push @constraints, 'ROME::Constraints::is_number';
	  }
	  if (my $min = $c->request->params->{element_value_min}){
	    push @constraints, 'ROME::Constraints::is_more_than('.$c->request->params->{element_value_min}.')';
	    $param->min_value($min);
	    $param->update;
	  }
	  if (my $max = $c->request->params->{element_value_max}){
	    push @constraints, 'ROME::Constraints::is_less_than('.$c->request->params->{element_value_max}.')';
	    $param->max_value($max);
	    $param->update;
	  }		  
	} #has numtype
      } #is text
      else {
	if ($c->request->params->{form_element_type} =~/^checkbox$/){
	  push @constraints,'ROME::Constraints::is_boolean';
	}
	else{
	  #type is one of checkbox_group, radio or select
	  #add is_one_of(list of options) constraint.
	  my @allowed_values = split /,|\//, $c->request->params->{'form_element_values'};
	  s/\s//g foreach @allowed_values;
	  push @constraints, 'ROME::Constraints::is_one_of(qw/'.(join ' ',@allowed_values).'/)';

	  #and, while we're at it add the constraint values to the database
	  $c->model('ROMEDB::ParameterAllowedValue')->create
	    ({
	      parameter_name                      => $param->name,
	      parameter_process_name              => $param->process_name,
	      parameter_process_component_name    => $param->process_component_name,
	      parameter_process_component_version => $param->process_component_version,
	      value                               => $_,
	     }) foreach @allowed_values;
	}
      } #isn't text
	  
      #element_is_multiple?
      unless ($c->request->params->{element_is_multiple}){
	unshift @constraints, 'ROME::Constraints::is_single';
      }

      #now insert those constraints into the DFV profile for this process
      #in your controller
      while (<>){
	#oooh, excuse to use the flip-floperator :)
	my $proc_name = $param->process_name;
	if (/^###\s+START\s+PROCESS\s+$proc_name/../^###\s+END\s+PROCESS\s+$proc_name/){
	  
	  #add the parameter name to required or optional
	  my $name = $param->name;
	  if ($param->optional){
	    s/^(\s*optional\s*=>\s*\[\s*qw\s*\()/$1$name /;
	  }
	  else{
	    s/^(\s*required\s*=>\s*\[\s*qw\s*\()/$1$name /;
	  }

	  #add an entry in the constraint methods for this parameter
	  if(s/^(\s*)(constraint_methods\s*=>\s*\{\s*)/$1$2$1  $name => \[/){
	    my $space = "$1     ";
	    $_ .= "\n$space".(join ",\n$space" ,@constraints). "\n$1  ],\n";
	  }
	  
	} #if proc_region

	print;

      } #while
    } #block

  }#if valid params
  else{
    return;
  }

  #report success
  $c->stash->{status_msg} = 'Parameter created';
  
  #and, because the parameter is added to the view and 
  #is constraints are added to the controller:
  $c->stash->{error_msg} = 'RESTART SERVER!';

}



=item process_template_upload_form

  Matches devel/process/template/upload_form
  Passes the process_template template
  to the view.


=cut
sub process_template_upload_form :Path('process/template/upload_form'){
  my ($self,$c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'devel/process_template';
}



sub _validate_process_template_upload :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw(process_name process_component_name process_component_version template_file)],
		     msgs => {
			      format => '%s',
			      constraints => 
			      {
			       'allowed_chars' => 'Please use only letters and numbers in this field',
			       'is_single' => 'Cannot take multiple values',
			       'process_exists' => 'Process not found',
			       'is_version' => "Doesn't look like a version number (major.minor.patch)",
			      },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    process_name => [
							     ROME::Constraints::is_single,
							     ROME::Constraints::allowed_chars,
							     ROME::Constraints::process_exists($c, 'process_component_name', 'process_component_version'),
						    ],
					    process_component_name => [
									ROME::Constraints::is_single,
									ROME::Constraints::allowed_chars,
								       ],
					    process_component_version => [
									  ROME::Constraints::is_single,
									  ROME::Constraints::is_version,
									 ]
					   },
		    };
 
 $c->form($dfv_profile);

}


=item process_template_upload

  Matches devel/process/template/upload

  Handler for the Ajax upload of new templates

  Form parameters:
  template_file - a file upload field
  process_name - name of the processes to which this template should be added
  process_component_name - name of the component to which that process belongs
  process_component_version - and the version of that component

=cut

sub process_template_upload :Path('process/template/upload'){
  my ( $self, $c ) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  #check permissions.
  unless($c->check_user_roles('dev')){
    $c->stash->{error_msg} = "You don't have permission to update process templates.";
    return;
  }
  
  #check param constraints
  return unless $c->forward('_validate_process_template_upload');
  
  #get upload file
  my $upload = $c->request->uploads;
  use Data::Dumper;
  warn Dumper $upload;
 
  
  my $filename = $c->config->{process_templates}
    .'/'.$c->request->params->{component_name}
      .'/'.$c->request->params->{process_name}.'tt2';
  
  #store the file, overwriting any existing
  #$upload->copy_to($filename);
  warn $filename;

  #success!
  $c->stash->{status_msg} = "Template successfully updated.";
}

=back

=cut


1;
