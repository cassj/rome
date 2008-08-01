#!/usr/bin/perl

=head1 NAME

script/rome_job_scheduler.pl

=head1 DESCRIPTION

This is the basic job scheduler daemon for ROME.

It checks the contents of the queue and runs (in order of submission) any
jobs for whom the input datafiles are ready. It will skip over anything still
with pending datafiles until it gets back round to the top.

It calls  ROME::JobScheduler::* class <process_name>_prepare and _complete
methods to setup the data and to process the results of the job, including
necessary database updates. The default prepare and complete methods defined
in ROME::JobScheduler::Base are fine for most simple processes.

=head1 USAGE

script/rome_job_scheduler.pl

=cut

use FindBin;
use lib "$FindBin::Bin/../lib";

use ROMEDB;
use Data::Dumper;
use YAML;
use POSIX qw(setsid);
use Path::Class;
use ROME::JobScheduler;
use File::chdir;

#script is always run from root dir.
my $rome_root  = dir();     
my $config =  YAML::LoadFile(file($rome_root, 'rome.yml'));

#connect to DB 
my $con = $config->{Model::ROMEDB}->{connect_info};
my $schema = ROMEDB->connect( $con->[0],$con->[1],$con->[2] );

&daemonize;

 while (1){

  my $queued = $schema->resultset('Queue')->search
    ({
      status => 'QUEUED',
     });
  
  while (my $q = $queued->next){

    #skip if datafiles are still pending
    my @datafiles = $q->job->in_datafiles;
    next if grep {$_->pending} @datafiles;

    run($q->job);

  }

   sleep(5);
}



sub daemonize {
  chdir('/');

  my $access_log = $config->{'process'}->{'access_log'};
  my $error_log = $config->{'process'}->{'error_log'};

  open STDIN,  '/dev/null' or die "Can't read /dev/null: $!";
  open STDOUT, '/dev/null' or die "Can't write to /dev/null: $!";
  open STDERR, '/dev/null' or die "Can't write to /dev/null: $!";
  
  defined(my $pid = fork)   or die "Can't fork: $!";
  exit if $pid;
  setsid                    or die "Can't start a new session: $!";
  umask 0;

}


sub run{
  my $job = shift;
 
  #do this bit in the user's directory
  my $userdir = dir($rome_root,'userdata', $job->owner->username);
  local $CWD = "$userdir"; 

  #get a job scheduler
  my $scheduler = ROME::JobScheduler->new($job);

  #Access stuff indirectly via prepared_job to give
  #process-specific JobSchedulers the chance to do
  #pre-processing and override stuff
  my $prepare = $job->process->name.'_prepare';
  my $prepared_job = $scheduler->$prepare;

  #run the job.
  my $script = $prepared_job->{script};
  my $pid = open(OUT, $prepared_job->{local_cmd}. "< $script 2>&1| ") 
    or die "Couldn't fork: $!\n";

  #open the log
  my $log = file($prepared_job->{log});
  $log = $log->open('>');

  #send the output to the log file
  while(my $line = <OUT>){
    print $log $line;
  }
  $log->close;

  #deal with the results
  if (close(OUT)){
    my $complete = $job->process->name.'_complete';
    $scheduler->$complete
  }
  else {
    my $halted = $job->process->name.'_halted';
    $scheduler->$halted
  }

}
