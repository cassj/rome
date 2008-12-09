package ROME::Controller::Admin;

use strict;
use warnings;
use base 'ROME::Controller::Base';
use ROME::Constraints;
use File::Find::Rule;
use Path::Class qw/file dir/;
use File::Copy::Recursive qw/fmove fcopy dirmove dircopy/;
use File::Path qw/mkpath rmtree/;
use File::Temp qw/tempfile tempdir/;
use IO::File;
use Cwd;

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

  #retrieve the selected component.
  my $component;
  if ($c->session->{component_name} && $c->session->{component_version}){
    $component = 
      $c->model('ROMEDB::Component')->find
	(
	 $c->session->{component_name},
	 $c->session->{component_version}
	);
  }
  $c->stash->{selected_component} = $component;
  $c->stash->{template} = 'admin/components'
}



=item install

  Installs a new component

=cut
sub install  :Path('component/install'){
  my ($self, $c) = @_;

  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'admin/upload_iframe';

  my $upload;
  unless ($upload = $c->request->uploads->{file}){
    $c->stash->{error_msg} = "No file uploaded";
    return
  }

  #check permissions.
  unless($c->check_user_roles('admin')){
    $c->stash->{error_msg} = "You don't have permission to install new components.";
    return;
  }

  #unpack into a tmpdir and then copy stuff over.
  my $dir = tempdir( CLEANUP => 0);
  my $file = file($dir,$upload->filename);
  $upload->copy_to("$file");

  #unpack it ?
  $self->_unpack("$file");
  my $compdir = dir($dir);
  ($compdir) = $compdir->children;

  my ($component_name) = $compdir =~/.*\/(.+)/ ;
  my ($sqlfile) = dir($compdir, 'sql')->children;

  #now run the sql
  my $db = $c->config->{'Model::ROMEDB'}->{name};
  my $user = $c->config->{'Model::ROMEDB'}->{connect_info}[1];
  my $pw = $c->config->{'Model::ROMEDB'}->{connect_info}[2];

  #FIX ME. MySQL quick hack
  my $cmd = "mysql -u". $user. " -p". $pw. " -D". $db ."< $sqlfile";
  system($cmd);

  #and copy the files over
  #Shortcuts to various locations
  my $root_dir = $c->config->{root};
  my ($template_dir) = $root_dir =~/(.+)root/;
  my $lib_dir = $template_dir;
  $template_dir .=$c->config->{process_templates};
  $lib_dir .= 'lib/ROME';

  #cp Component Controller:
  my $file2 = "$lib_dir/Controller/Component/".$component_name.".pm";
  my $file1 = $compdir.'/lib/ROME/Controller/Component/'.$component_name.".pm";
  unless(fcopy($file1, $file2)){
    $c->log->error("failed to copy controller for ".$component_name." $!");
    $c->stash->{error_msg} = "Installation failed, see log for details";
    return;
  }

  #cp View templates
  $file2 = "$root_dir/src/component/".$component_name;
  $file1 = $compdir."/root/src/component/".$component_name;
  unless(dircopy($file1, $file2)){
    $c->log->error("failed to copy view templates for ".$component_name." $!");
    $c->stash->{error_msg} = "Installation failed, see log for details";
    return;
  }

  #cp Process templates
  $file2 = "$template_dir/".$component_name;
  $file1 = $compdir."/process_templates/".$component_name;
  unless(dircopy($file1, $file2)){
    $c->log->error("failed to copy process templates for ".$component_name." $!");
    $c->stash->{error_msg} = "Installation failed, see log for details";
    return;
  }

  my $msg = 'File '. $upload->{filename}.' successfully installed. Please restart your ROME server';

  #success!

  $c->stash->{status_msg} = $msg;

}



sub _get_unpack_cmd(){
   my ($self, $file) = @_;

   die 'no file given' unless $file;

   #get the file's MIME type:
   my $mm = File::MMagic->new();
   my $mime = $mm->checktype_filename("$file");
   my $cmd = "";

   $_ = $mime;
   SWITCH: {
       /application\/x-gtar/ && do {
          $cmd = "tar -xf ";
	  last SWITCH;
       };

       /application\/x-gzip/ && do {
         if ($file =~ /tgz|tar.gz/) {
	  $cmd = "tar -xzf " ;
	 }
	 else{
	  $cmd = "gunzip -f ";
	 }
	  last SWITCH;
       };

       /application\/x-bzip/ && do {
         if ($file =~ /tbz|tar.bz|tbz2|tar.bz2/) {
           $cmd = "tar -xjf ";
	 }
	 else{
	   $cmd = "bunzip2 -f ";
	 }
	  last SWITCH;
       };

       /application\/x-zip/ && do{
         if ($file =~ /tZ|tar.Z/) {
           $cmd = "tar -xZf ";
	 }
	 else {
	   $cmd = "unzip ";
	 }
	  last SWITCH;
       };

   };

    return ($cmd);

}



#this just unpacks the given file.
sub _unpack {
   my ($self, $path) = @_;

   die "File doesn't exist" unless -e $path;

   #can we get an unpack cmd based on the filename 
   my $cmd = $self->_get_unpack_cmd("$path");
   
   #no?
   unless ($cmd){
    #store file as is, but warn
    warn "No unpack method for file:\n\t $path, \n\tleaving as it is\n";
    return [$path];
   }

   #ok, go ahead and unpack the file 
   my ($dir, $file) = $path =~ /(.*)\/(.*)\/?/;
   my $cwd = getcwd(); 
   chdir($dir);
   system("$cmd $file"); 
   chdir($cwd);

   #and ditch the original file
   unlink $path;   
   
   return 1;

}


#not actually using this. Might do - would need install to 
#fork and do the update, editing the $c->stash->{install_msg}
#plus the start_install_monitor js would need to be enabled in the 
#upload_iframe tt file.
sub install_monitor :Path('component/install/monitor'){
  my ($self, $c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = "admin/installmonitor";
   
  if ($c->session->{install}){
    $c->stash->{status_msg} = $c->session->{install_msg};
    if ($c->session->{install} eq "DONE" || $c->session->{install} eq 'FAIL'){
      $c->stash->{stop_monitor}=1;
    }
    
  }


}

=item uninstall

  Uninstalls the currently selected component.

=cut
sub uninstall  :Path('component/uninstall'){
  my ($self, $c) = @_;

  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;

  #check permissions.
  unless($c->check_user_roles('admin')){
    $c->stash->{error_msg} = "You don't have permission to uninstall components.";
    return;
  }

  my $component;
  #retrieve the selected component.
  if ($c->session->{component_name} && $c->session->{component_version}){
    $component = 
      $c->model('ROMEDB::Component')->find
	(
	 $c->session->{component_name},
	   $c->session->{component_version}
	);
  }
  unless ($component){
    $c->stash->{error_msg} = "Failed to uninstall, please check the log files for details";
    $c->log->error("Failed to uninstall ".$c->session->{component_name}.". Couldn't retrieve component");
    return;
  }
    
  #Shortcuts to various locations
  my $root_dir = $c->config->{root};
  my ($template_dir) = $root_dir =~/(.+)root/;
  my $lib_dir = $template_dir;
  $template_dir .=$c->config->{process_templates};
  $lib_dir .= 'lib/ROME';
  
  #Remove all the files associated with this component
  my $component_pm = "$lib_dir/Controller/Component/".$component->name.".pm";
  my $view_dir = "$root_dir/src/component/".$component->name;
  my $proc_tmpl_dir = "$template_dir/".$component->name;
  
  unless((! -e $component_pm) || unlink $component_pm){
    $c->stash->{error_msg} = "Failed to uninstall, please check the log files for details";
    $c->log->error("Failed to uninstall ".$component->name.". Couldn't unlink $component_pm");
    return;
  }
  
  unless((! -e $view_dir) ||rmtree $view_dir){
    $c->stash->{error_msg} = "Failed to uninstall, please check the log files for details";
    $c->log->error("Failed to uninstall ".$component->name.". Couldn't remove $view_dir");
    return;
  }
  unless( (! -e $proc_tmpl_dir) || rmtree $proc_tmpl_dir){
    $c->stash->{error_msg} = "Failed to uninstall, please check the log files for details";
    $c->log->error("Failed to uninstall ".$component->name.". Couldn't remove $proc_tmpl_dir");
    return;
  }
  #and switch the installed flag in the DB. We don't want to completely
  #remove it as we need to keep track of which versions were used for 
  #processes already run
  $component->installed('0');
  $component->update;
  
  undef $c->session->{component_name};
  undef $c->session->{component_version};
  
  #success!
  $c->stash->{status_msg} = $component->name." successfully uninstalled. Please restart your ROME server";
 
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

  Matches admin/component/select

=cut
sub select_component :Path('component/select'){
  my ($self,$c) = @_;
  $c->stash->{template} = 'site/messages';
  $c->stash->{ajax} = 1;
  
  unless ($c->check_user_roles('admin')){
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
    unless ($comp->installed){
      $c->stash->{error_msg} = 'Component is not installed';
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


=item component_autocomplete

  Matches admin/component/autocomplete

  Generates a list of component names to be formatted as
  a prototype.js autocompleter list

=cut
sub component_autocomplete :Path('component/autocomplete') {
  my ($self,$c) = @_;
  return unless $c->check_user_roles('admin');

  my $val = $c->request->params->{component_name};
  $val =~ s/\*/%/g;
  $c->stash->{ajax} = 1;

  my $components =  $c->model('ROMEDB::Component')->search_like({name=>'%'.$val.'%',
								 installed => 1});
  

  $c->stash->{template} = 'admin/component_autocomplete';
  $c->stash->{components} = $components;

}



=item selected_component

  Matches admin/component/selected

  Ajax: returns the current component details

=cut
sub component_selected :Path('component/selected'){
  my ($self, $c) = @_;
  $c->stash->{template} = 'admin/selected_component';
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


=item component_remove

  Matches admin/component/remove

  Ajax: returns the form for removing the current component.
  
  Note: This doesn't actually do the removal, see the uninstall method for that.
        this is just called by the front end to update the remove form when a 
        component is selected.

=cut
sub component_remove :Path('component/remove'){
  my ($self, $c) = @_;
  $c->stash->{template} = 'admin/remove_component';
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




=back

=cut

1;
