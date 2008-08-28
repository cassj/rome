=head1 NAME

  ROME::Processor::Base

=head1 SYNOPSIS

  use ROME::Processor

=head1 ABSTRACT

  Base class for ROME processors.


=head1 DESCRIPTION

  This is the base class for ROME processors. It can be subclassed to 
  generate new processors. See ROME::Processor::R for an example.

  This is not the class to use in your ROME controllers to get a
  processor object. Use the ROME::Processor factory class, eg
 
  my $R = new ROME::Processor('R');

=cut


package ROME::Processor::Base;

use strict;
use warnings;

use Data::Compare;
use Data::FormValidator;
use FileHandle;
use DateTime;
use File::Which;
use Path::Class;

use Storable qw/freeze thaw/;


use base qw[Class::Accessor::Fast Class::Data::Inheritable];
__PACKAGE__->mk_accessors (qw|context 
                              process 
                              confirm_by_email 
                              datafile_ids 
                              class 
                              user 
                              script 
                               _suffix 
                              arguments 
                              config 
                              out
			      job
			     |);

our $VERSION = '0.01';

use Template;
use Storable;
use File::Temp;
use YAML;

=head2 new

 Creates a new process instance. 
 Expects the catalyst context as an argument

=cut

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

=head2 cmd_name

  This should be implemented in the subclass to return the name
  of the processor executable, eg 'R'

=cut
sub cmd_name{
    die "Base method called. Override this is your subclass";
}

=head2 cmd_params

  Base method returns an empty string. 
  Override in your subclass if you want to pass parameters to the cmd
  eg. '--slave --vanilla'

=cut
sub cmd_params{
    warn "Base cmd_params called. If your cmd should have parameters you need to override this method in your base class";
    return '';
}

=head2 cmd

    Attempts to locate the executable named by cmd_name on the machine.
    If an environment variable ROME_PROCESSOR_<PROCESSOR_NAME> is set then
    that path will be used (note processor name is all in uppper case). 
    Failing that File::Which is used to locate the executable 
    in the path.

=cut

sub cmd {
    my $self = shift;
    my $path;
    my $env_var = uc ref $self;
    $env_var =~ s/::/_/g;
    unless ($path = $ENV{$env_var}) {
	$path = File::Which::which($self->cmd_name);
    }
    die "executable not found" unless ($path && -x $path);
    return $path;

}

=head2 queue

  Creates a job from this processor and the associated process
  and adds it to the job queue.

  Expects to be given a single string as an argument which can be used
  as a prefix to the generated file names.

=cut

#  NOTE TO SELF: SPLIT THIS UP INTO READABLE SUBS!

sub queue{

  my $self = shift;

  ### 
  # Check processor has all the info it needs to queue a job

  die "Can't queue a job with no context" unless $self->context;
  die "Can't queue a job with no process" unless $self->process;
  warn "Queuing job with no arguments" unless $self->arguments; 

  ###
  # Check user has write permissions on this experiment

  my $expt_name = $self->context->user->experiment_name;
  my $expt_owner = $self->context->user->experiment_owner;

  unless ($expt_owner->username eq $self->context->user->username || $self->context->check_user_roles("admin")){
    $self->context->stash->{error_msg} = "You can't create files in someone else's experiment";
    return 0;
  }
  
  ####
  # Check the process in question is active
  
  unless ($self->context->session->{active_processes}
	  && $self->context->session->{active_processes}->{processes}
	  -> {$self->process->component_name}
	  -> {$self->process->component_version}
	  -> {$self->process->name}){
      $self->context->stash->{error_msg} = "Unsuitable datatypes selected";
      return 0;
  }

  ###
  # check that the contents of $self->arguments match up to those defined for 
  # this process in the database.
  my %params;
  $params{$_->name}++
    for $self->process->parameters;

  foreach (keys %{$self->arguments}){
    unless (defined $params{$_}){
      $self->context->stash->{error_msg} = "Invalid argument: $_";
      # validity checks on the params are performed by the controller
      # which calls the process and also by the R script to which they
      # are passed
      return;
    }
  }

  
  # constraint checks should have been done by the controller which 
  # uses the processor

  ###
  #create a job (can't get duplicate entries - auto increment ID)
  my $job = $self->context->model('ROMEDB::Job')->create(
		   {
		    owner=> $self->context->user->username,
		    experiment_name => $self->context->user->experiment->name,
		    experiment_owner => $self->context->user->experiment->owner->username,
		    process_name=>$self->process->name,
		    process_component_name => $self->process->component_name,
		    process_component_version => $self->process->component_version,
		   });

  #and now we've got a job ID, create a log file.
  my $log_file = file($self->context->config->{userdata},$self->context->user->username,'logs',("job_".$job->id));

  my $fh = $log_file->openw or die "Can't open logfile $log_file";
  print $fh 'Created job with ID '.$job->id;
  undef $fh;
  $job->log($log_file);

  #keep a note of the job
  $self->job($job);
  $self->job->update;


  ###
  # Add the arguments to the job 
  foreach (keys %{$self->arguments}){

    my $vals = $self->arguments->{$_};
    $vals = ref($vals) eq 'ARRAY' ? $vals : [$vals];
    foreach my $val (@$vals){

      my $arg = $self->context->model('ROMEDB::Argument')->create(
		    {
		     jid => $job->id,
		     parameter_name => $_,
                     parameter_process_name => $self->process->name,
		     parameter_process_component_name => $self->process->component_name,
		     parameter_process_component_version => $self->process->component_version,
                     value => $val,
		    });
    }
  }

  #if we've got selected_outcomes, also store their objects and link them to the datafile
  my @selected_outcome_objects;
  my @outcomes = ref $self->arguments->{selected_outcomes} ? @{$self->arguments->{selected_outcomes}} : ($self->arguments->{selected_outcomes}); 
  foreach (@outcomes){
    my $outcome =  $self->context->model('ROMEDB::Outcome')->find
      (
       $_,
       $self->context->user->experiment->name, 
       $self->context->user->experiment->owner->username,
      );

    push @selected_outcome_objects, $outcome;
  }

  if ($#selected_outcome_objects){
    $self->arguments->{selected_outcome_objects} = \@selected_outcome_objects;
    $self->arguments->{selected_outcome_display_names} = [map {$_->display_name} @selected_outcome_objects];
  }

  ###
  # Process_accepts should be used here. 
  my $is_root = 1;

  # need to map the datatypes of the input datafiles to the datatypes of the 
  # accepted datafiles and assign names appropriately.

  #use the mapping table, not the m2m as it has the name in it.
  foreach ($self->context->user->datafiles){
    $is_root = 0; #if we've got input datafiles, we're not a root.

    #pull the appropriate process_accepts.
    my $pc = $self->context->model('ROMEDB::ProcessAccepts')->search
      ({
	process_name => $self->process->name,
	process_component_name  => $self->process->component_name,
	process_component_version => $self->process->component_version,
	datatype_name => $_->datatype->name,
       });

    #what if we have multiple process_accepts of the same datatype? 
    #really need to add something to the process params that will allow you to
    #assign particular input files to particular proc_acc names.
    #as long as it automatically maps by datatype when there's only one, it should
    #be back compat.
    my $pa_name;
    if ($pc->count == 1){
      $pa_name = $pc->next->name;
    }
    else{
      #do some as yet unspecified thing.
    }
    

    #ok add the files to the job (jid so always unique)
    my $in_file = $self->context->model('ROMEDB::InDatafile')->create
      ({
	jid => $job->id,
	datafile_name => $_->name,
	datafile_experiment_name=> $_->experiment_name,
	datafile_experiment_owner =>$_->experiment_owner,
       });

    #and add the infile to the tmpl args
    $self->arguments->{rome_datafiles_in}->{$pa_name} = $in_file->datafile;
  }
  
  $job->is_root($is_root);
  $job->update;





  ###
  #create placeholder datafiles for everything this process will create.
  #note that we use process_creates,to get the mapping table, rather than 
  #creates which is the many-to-many straight through to the datatype.


  my $dir = dir($self->context->config->{userdata}, $self->context->user->username);

  my $datafiles = {};
  foreach ($self->process->process_creates){

    my $name = $_->name.'_'.$job->id;
    $name.= '.'.$_->suffix if $_->suffix;

    my $path = file($dir,$name);

    #check we haven't already got stuff with that name
    my $datafile = $self->context->model('ROMEDB::Datafile')->find(
             {
	      name => $name,
	      experiment_name => $expt_name,
	      experiment_owner => $expt_owner->username,
	     });
    my $datafile_pending = $self->context->model('ROMEDB::DatafilePending')->find(
	      {
	       datafile_name => $name,
	       datafile_experiment_name => $expt_name,
	       datafile_experiment_owner => $expt_owner->username,
	      });
    
    #if datafile exists, bail and tell the user
    if ($datafile){
      $self->context->stash->{error_msg} = "A datafile of that name already exists, please choose another";
      return 0;
    }

    # if only the pending file exists, something's gone wrong but if it's not
    # fatal yet it probably won't be. Delete it.
    if ($datafile_pending){
      $datafile_pending->delete;
    }


    #create the datafile.
    $datafile = $self->context->model('ROMEDB::Datafile')->create(
	 {
	  name    => $name,
	  experiment_name => $expt_name,
	  experiment_owner => $expt_owner->username,
	  datatype => $_->creates,
	  status => 'private',
	  job_id => $job->id,
	  is_root => $is_root,
	  path => $path,
	 });


    #mark it as pending
    $datafile_pending = $self->context->model('ROMEDB::DatafilePending')->create(
	  {
	   datafile_name=> $datafile->name,
	   datafile_experiment_name=> $datafile->experiment_name,
	   datafile_experiment_owner=>$datafile->experiment_owner,
	  });


    #if we've got selected outcomes, add them to the datafile
    if ($#selected_outcome_objects){
      foreach (@selected_outcome_objects){
	$self->context->model('ROMEDB::OutcomeDatafile')->create
	  ({
	    outcome_name => $_->name,
	    outcome_experiment_name => $_->experiment_name,
	    outcome_experiment_owner => $_->experiment_owner,
	    datafile_name => $datafile->name,
	    datafile_experiment_name => $datafile->experiment_name,
	    datafile_experiment_owner => $datafile->experiment_owner,
	   });
      } 
    }

    #and pass it to the template (name as in process_creates)
    $self->arguments->{rome_datafiles_out}->{$_->name} = $datafile;

  }
  
  #parse the template in the current context and queue it.
  $self->parse_template;

  $self->context->stash->{status_msg} = 'Your job has been queued for processing.' 
                                        .'You can monitor its progress on the <a href="'
					  .$self->context->uri_for('/job')
					    .'">jobs</a> page.'
					  . 'It has Job ID: '. $job->id;
}

#################################################################
# parse the contents of $self->tmpl, with the contents of $arguments
# into a tmp file, with suffix $self->suffix
# put the resulting files into $self->scripts

sub parse_template {

  my $self = shift;

  die "Set process before parsing" unless $self->process->tmpl_file;
  die "Set arguments before parsing" unless $self->arguments;
  die "No suffix defined for this processor" unless $self->_suffix;

  #store scripts in the userdir
  #my $dir = $self->context->config->{tmp_job_files};
  my $dir = dir($self->context->config->{userdata}, $self->context->user->username,'scripts');

  my $script = new File::Temp( SUFFIX => '.'.$self->_suffix, UNLINK=>0, DIR=>$dir);

  my $tmpl_dir = dir($self->context->config->{process_templates});

  # should this stuff be in the yaml file? 
  my $tt_config = {
      INCLUDE_PATH => "$tmpl_dir",
      INTERPOLATE  => 1,
      POST_CHOMP   => 1,
      EVAL_PERL    => 1,
  };

  # create Template object
  my $template = Template->new($tt_config);

  #add your current cat context
  $self->arguments->{Catalyst} = $self->context;
  
  #add database connection details (TT chokes on Model::ROMEDB as a hash key)
  $self->arguments->{ROMEDB} = $self->context->config->{'Model::ROMEDB'};

  my $file = file($self->process->component_name,$self->process->tmpl_file);

  #generate the script
  $template->process("$file", $self->arguments, $script)
    || die $template->error();

  #store result
  $self->context->log->debug("Script parsed to: $script");
  $self->job->script($script);
  $self->job->update;

  
  #How lovely is this ?!
  my $dt = DateTime->now;

  #ok, add it to the queue
  my $q = $self->context->model('ROMEDB::Queue')->create(
               {
		jid => $self->job->id,
		status => 'QUEUED',
		start_time => $dt,
		owner => $self->context->user->username,
	       });

}


#This shouldn't be in here, it's a thing for the job scheduler.
###################################################
#sub send_email_confirmation{
# 
# my $self = shift;
#  
# die "Can't send email without a user" unless $self->user;
# die "Can't send email without a config" unless $self->config;
# die "Can't send email without a process" unless $self->process;
#
# if ($self->confirm_by_email)
#    { 
#      my $sendmail = $self->config->{sendmail};
#      my $from = $self->config->{noreply_email};
#      my $subject  = "Message from R-OME";
#      my $to       = $self->user->email;
#      my $username = $self->user->username;
#      my $realname = $self->user->forename.' '.$self->user->surname;
#      my $proc_name = $self->process->name;
#      my $proc_desc = $self->process->description;
#      
#      open(MAIL, "| $sendmail -t");
#      print MAIL "To:$to\n"
#	."From:$from\n"
#	  ."Subject: $subject\n"
#	    ."R-OME has completed the processing of $proc_name ($proc_desc).\nResulting datafiles will be available from "
#	      .$self->config->{base_href}	
#		."/WebR/datafiles";
#      close MAIL or die "Problem sending mail.";
#    }  
#}
#
#######################################
#sub send_admin_alert{
#
# my $self = shift;
#  
# die "Can't send email without a user" unless $self->user;
# die "Can't send email without a config" unless $self->config;
# die "Can't send email without a process" unless $self->process;
#
# if ($self->confirm_by_email)
#    { 
#      my $sendmail = $self->config->{sendmail};
#      my $from = $self->config->{noreply_email};
#      my $subject  = "R-Ome Process Failed";
#      my $to       = $self->config->{admin_email};
#      my $username = $self->user->username;
#      my $realname = $self->user->forename.' '.$self->user->surname;
#      my $proc_name = $self->process->name;
#      my $proc_desc = $self->process->description;
#      
#      open(MAIL, "| $sendmail -t");
#      print MAIL "To:$to\n"
#	."From:$from\n"
#	  ."Subject: $subject\n"
#	    ."R-OME failed to complete the processing of $proc_name ($proc_desc) for user $username ($realname).";
#      close MAIL or die "Problem sending mail.";
#    }  
#
#}

########################################
#sub process_script
#  {
#    my $self = shift;
#   
#    die "Nothing in $self->script. Parse template first" unless $self->script;
# 
#    my $script = $self->script;
#
#    #STDERR/STDOUT to a filehandle
#    my $pid = open(OUT, $self->cmd." < '$script' |") 
#      or die "Couldn't fork: $!\n";
#
#    my ($line, $out);
#    while($line = <OUT>)
#      {
#	print STDERR $line;
#	#$out->{$1}= [split /,/,$2] if $line=~/^([\w|\-]+)\?(.+$)/;
#       }
#	
#    if (close(OUT)){
#      $self->send_email_confirmation;
#    }
#    else
#      {
#	die "Problem with process ".__PACKAGE__." : $!";
#	$self->send_admin_alert;
#      }
#    
#      $self->out($out);
#  }




1;

