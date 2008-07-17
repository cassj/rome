#!/usr/bin/perl;

# This script should be started when you start R-OME.
# it keeps track of pending processes and runs them when the datafile they require is ready.

use FindBin;
use lib "$FindBin::Bin/../lib";

use ROMEDB;
#use WebR::M::CDBI;
use Data::Dumper;
use YAML;
use POSIX qw(setsid);


#use lib '/srv/www/WebR/lib';

	
my $rome_root = $ARGV[0];
my $config =  YAML::LoadFile("$rome_root/webr.yml");


&daemonize;

while (1){
  my $pending = WebR::M::CDBI::ProcessPending->retrieve_all;

  #This will only deal with processes running on a single datafile. 
  #Should this be a many-to-many? Feasibly a process might require multiple datafiles?

  while (my $proc = $pending->next){
    next if $proc->datafile->pending;
    next unless $proc->status eq 'QUEUED';
    warn "Starting Process ".$proc->id;
    &run($proc);
  }
  
  sleep(5);
}


sub run{
  my $proc_pending =shift;
  
  #setup
  warn "setup";
  
  my $user =  $proc_pending->person; 
  
  #grab an empty processor so we get the fxns we need.
  my $processor = $proc_pending->processor;
  eval "require $processor";
  my $processor = $processor->new();
  
  #add relevant bits to the processor
  $processor->script($proc_pending->script);
  $processor->config($config);
  $processor->user($user);  
  $processor->process($proc_pending->process);

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
    localtime();
  
  $year=$year+1900;
  $mon++;
  print "\nTIME: $year-$mon-$mday $hour:$min:$sec \n";
  $proc_pending->start_time("$year-$mon-$mday $hour:$min:$sec");
  
  warn "processing";
  $proc_pending->status('PROCESSING');
  $proc_pending->update;
  
  #RUN!
  #This should actually just queue the job on the farm. 
  warn "running";
  eval {
    $processor->process_script
  };
  if($@){
    $proc_pending->status('HALTED');
    $proc_pending->update;
    return 0;
  }  
  
  #note - the R script deals with removing the pending flag on the new datafiles. see Webr.R register_datafile
  
  #and this should probably happen as a response to completion of a job on the farm.
  warn "finishing";
  $proc_pending->delete;

  warn "DONE";
}



sub daemonize {

  chdir('/');
  
  my $access_log = $config->{'process'}->{'access_log'};
  my $error_log = $config->{'process'}->{'error_log'};
 
  open STDIN,  '/dev/null' or die "Can't read /dev/null: $!";
  open STDOUT, ">>$access_log" or die "Can't write to $access_log: $!";
  open STDERR, ">>$error_log" or die "Can't write to $error_log: $!";
  
  defined(my $pid = fork)   or die "Can't fork: $!";
  exit if $pid;
  setsid                    or die "Can't start a new session: $!";
  umask 0;
  
}

