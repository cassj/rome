=head1 NAME

  ROME::JobScheduler::Base

=head1 SYNOPSIS

  use base 'ROME::JobScheduler::Base';

=head1 ABSTRACT

  Base class for ROME job schedulers.

  This class is used as a base class for new job schedulers in ROME
  and should never be used directly. The ROME::JobScheduler factory
  class is used by script/rome_job_scheduler.pl to retrieve an instance
  of an appropriate job scheduler class for a given job.


=head1 DESCRIPTION

  This class defines basic functions for scheduling jobs in ROME and
  will be used by default unless there is a specific JobScheduler subclass
  defined for the component to which the process in the current job belongs. 
  It will also be used if there is no run_<process_name> method in a component-
  specific job scheduler.

  Unless you need to do anything particularly complicated at the job scheduling 
  stage, like parallelising your job, then you don't really need to care about this
  Everything should Just Work.


=cut


package ROME::JobScheduler::Base;

use strict;
use warnings;
use Sub::Auto;
use ROME::Processor;
use YAML;

our $VERSION = '0.01';

=head2 new

 Creates a new job scheduler instance. 
 Expects a job (ROMEDB::Job) object and
 schema (DBIx::Class schema) as arguments

=cut

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->{job} = shift or die "No job supplied";
    die "Job not of class ROMEDB::Job" unless ref($self->job) eq 'ROMEDB::Job';
    $self->{schema} = shift or die "No schema supplied";
    return $self;
}


=head2 job

  Accessor for the job to be scheduled.
  NOT writable. You need to create a new Job Scheduler
  instance for every job.

=cut

sub job{
  my $self = shift;
  return $self->{job};
}


=head2 schema

  ROMEDB schema object

=cut
sub schema{
  my $self = shift;
  return $self->{schema};
}


=head2 prepare

  The default prepare function. Don't call this directly, use
  <process_name>_prepare. If there isn't one defined it will
  default to here.

  If you need to do some preprocessing for your process you can 
  override this method in 
  ROME::JobScheduler::<ComponentName>-><process_name>_prepare


  All prepare actions should return a hash with required values
  for keys:

  executable = binary to be run
  input = file to redirect as STDIN
  output = file to redirect STDOUT
  error = file to redirect STDERR
  argument = arguments to binary

  The following keys are optional, and are ignored by the 
  basic job scheduler, but for optimal use of condor it is
  best to set them if your job has significant processor or data 
  requirements. At least define a version of R and any libraries that
  are required.

  requirements = characteristics of a machine capable of running this
                 job. Ignored by the basic job scheduler, but used in condor
  rank = Some calculation to determine preferred target machines 

=cut
sub prepare{
  my $self = shift;

  #do this first so we don't try and run it again.
  $self->job->queued->status('RUNNING');

  my $processor = ROME::Processor->new($self->job->process->processor);
  my $prepared = {};
  $prepared->{executable}    = $processor->cmd;
  $prepared->{arguments}     = $processor->cmd_params;
  $prepared->{script}        = $self->job->script;
  $prepared->{in_datafiles}  = [map {$_->path} $self->job->in_datafiles];
  $prepared->{log}           = $self->job->log;

  return $prepared;
}


=head2 complete

  The default complete function. Don't call this directy, use
  <process_name>_complete. If there isn't one defined it will
  default to here.


  If you need to do more complicated post-processing of your 
  process output than is available in the default method, you
  can override it in 
  ROME::JobScheduler::<ComponentName>-><process_name>_complete


=cut
sub complete{
  my $self = shift;
  
  #update the job status
  $self->job->completed(1);
  
  #delete the entry in the queue
  $self->job->queued->delete;

  #set the datafiles as no longer pending.
  $_->pending->delete foreach $self->job->out_datafiles;
  
}

=head2 halted

  The default halted function. Don't call this directy, use
  <process_name>_halted. If there isn't one defined it will
  default to here.

  If you need to do more complicated error handling than
  is available in the default method, you can override it in 
  ROME::JobScheduler::<ComponentName>-><process_name>_halted

=cut
sub halted{
  my $self = shift;

  warn "Halting job ". $self->job->log;

  #remove this job from the queue.
  $self->job->queued->delete;

  #and remove any downstream jobs and datafiles altogether
  $self->_delete_datafiles($_) foreach $self->job->out_datafiles;

  $self->email_admin_error;
  $self->email_user_error;
}


#recursive method to ditch jobs and child datafiles
sub _delete_datafiles{
  my ($self, $df) = @_;
  
  while (my $job = $df->input_to){
    $self->_delete_datafiles($_) foreach $job->out_datafiles;
    $job->delete;
  }
  $df->delete;
  return;
}

=head2 email_admin_error

  let the administrator know when something has gone wrong

=cut
sub email_admin_error{
  my $self = shift;

}

=head2 email_user_error

  let the user know when something has gone wrong

=cut
sub email_user_error{
  my $self = shift;
}

=head2 email_user_success

 lt the user when their job has completed successfully

=cut
sub email_user_success{
  my $self = shift;
}


#Auto::Sub that hands over anything that looks like
#<processname>_prepare to the default run.
autosub ((.+)_prepare$) {
  my $process = shift;
  my $self = shift;
  $self->prepare(@_);
 };



#and similarly for halted
autosub ((.+)_halted$) {
  my $process = shift;
  my $self = shift;
  $self->halted(@_);
 };


#and for complete
autosub ((.+)_complete$) {
  my $process = shift;
  my $self = shift;
  $self->complete(@_);
 };



1;
