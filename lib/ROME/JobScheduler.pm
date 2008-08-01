=head1 NAME

  ROME::JobScheduler

=head1 SYNOPSIS

  use ROME::JobScheduler;
  my $scheduler = new ROME::JobScheduler($job);

=head1 DESCRIPTION

  Factory class for ROME job schedulers

  Used by script/rome_job_scheduler.pl

  If you're writing a job scheduler for you component, the 
  class you should be inheriting from is ROME::JobScheduler::Base.

=cut

package ROME::JobScheduler;

use strict;
use warnings;

use Class::Factory::Util;

sub new {
  my $self = bless {}, shift;
  my $job = shift;

  unless ($job){
    warn 'No job supplied. Usage: ROME::JobScheduler->new($job)';
    return undef;
  }

  #do we have a subclass defined for the component to which 
  #the process belongs?
  my $subclass = $job->process->component_name;
  my %subclasses = map {$_=>1} __PACKAGE__->subclasses;
  my $class = $subclasses{$subclass} ?
    "ROME::JobScheduler::$subclass" :
      "ROME::JobScheduler::Base";

  #return an instance of the appropriate job scheduler
  eval "require $class" or die "require failed for $class";
  my $newInstance =  $class->new($job, @_);
  return $newInstance;

}





1;

