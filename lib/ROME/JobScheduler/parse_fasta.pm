=head1 NAME

  ROME::JobScheduler::parse_fasta

=head1 SYNOPSIS

  Don't use this directly, use ROME::JobScheduler.

=head1 ABSTRACT

  JobScheduler code for the parse_fasta component

=cut

package ROME::JobScheduler::parse_fasta;
our $VERSION = '0.01';

use base qw/ROME::JobScheduler::Base/;

use FileHandle;
use JSON;

=head2 parse_fasta_complete

  Override the base complete method to parse the JSON outcomes that the
  fasta parser writes to its log file.

=cut
sub parse_fasta_complete{
  my $self = shift;

  #open the job log file and scan through it for outcomes. 
  my $logfile = $self->job->log;

  my $fh = new FileHandle;
  $fh->open('<'.$self->job->log) or die "Can't open log file";
  
  my @outcomes;
  while (<$fh>) {
    if (/START_JSON/ .. /STOP_JSON/) {
      #the json is spat out as a single line. just parse it.
      next if /^\s*$/; #skip blank lines
      next if /JSON$/; #and the marker lines
      push @outcomes, decode_json $_;
    }
  }
  $fh->close;

  #now find or create the outcome and link it to the datafile.
  foreach (@outcomes){

    my $out =  $self->schema->resultset('Outcome')->find_or_create
      ({
	name => $_->{outcome_name},
	experiment_name=>  $_->{outcome_experiment_name},
	experiment_owner=> $_->{outcome_experiment_owner},
	display_name => $_->{outcome_display_name} || $_->{outcome_name},
      });

    my $df_out = $self->schema->resultset('OutcomeDatafile')->find_or_create
      ({
	outcome_name => $_->{outcome_name},
        outcome_experiment_name  => $_->{outcome_experiment_name},
	outcome_experiment_owner => $_->{outcome_experiment_owner},
	datafile_name => $_->{datafile_name},
	datafile_experiment_name => $_->{datafile_experiment_name},
	datafile_experiment_owner => $_->{datafile_experiment_owner}
       });

  }

  #and call the default complete to do the rest
  $self->SUPER::complete;

}


1;
