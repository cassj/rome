package ROME::Controller::Job;

use strict;
use warnings;
use base 'ROME::Controller::Base';
use ROME::Constraints;

=head1 NAME

ROME::Controller::Job - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=over 2

=cut


=item index 

   matches /job
   
   hands job/main to the view

=cut

sub index : Private{
  my ($self, $c) = @_;
  
  #return an admin GUI page 
  $c->stash->{template} = 'job/main';
}


=item queue 

  Matches /job/queue
  Ajax. Hands job/queue to the view.

=cut 
sub queue: Local{
  my ($self,$c) = @_;
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'job/queue'; 
}


sub _validate_delete : Private{
  my ($self,$c) = @_;
  my $dfv_profile = {
		     required => [qw(jid)],
		     msgs => {
			      format => '%s',
			      constraints => {
					      'is_single' => 'Multiple values for jid not allowed',
					      'is_integer' => "Doesn't look like a job id",
					      'is_more_than' => "Doesn't look like a job id",
					      'job_exists' => 'Job not found',
					     },
			     },
		     filters => ['trim'],
		     missing_optional_valid => 1,    
		     constraint_methods => {
					    jid => [
						    ROME::Constraints::is_single,
						    ROME::Constraints::is_integer,
						    ROME::Constraints::is_more_than(0),
						    ROME::Constraints::job_exists($c),
						    ],

					   },
		    };
 
 $c->form($dfv_profile);
}

=item queue_delete

  Matches /job/delete
  
  ajax.

  Deletes a job. 
  Will cause cascading deletion of any downstream 
  datafiles and jobs and will remove the job from the
  queue if it is not yet complete. 

  If a job is being run somewhere, its results will just be 
  chucked away when it returns.

  Expects parameters:
  jid: the id of the job


=cut

sub delete : Local{
  my ($self, $c) = @_;
  
  $c->stash->{ajax} = 1;
  $c->stash->{template} = 'site/messages';
  
  if ($c->forward('_validate_delete')){
    #retrieve the job
    my $job = $c->model('ROMEDB::Job')->find($c->request->params->{jid});
    die "job $job not found" unless $job;

    #check user permissions
    unless ($c->check_user_roles('admin') || ($c->user->username eq $job->owner->username)){
      $c->stash->{error_msg} = "You don't have permission to delete that job";
      return;
    }
    
    #ok, delete the job. Need to start with any jobs that are queued on it,
    if (_delete_job($job)){
      $c->stash->{status_msg} = "Job deleted";
      return 1;
    }
    else{
      return;
    }
    
  }
}

sub _delete_job{
  my $job = shift;
  
  #delete the output files from the job
  while (my $datafile = $job->out_datafiles->next){
    while (my $next_job = $datafile->input_to->next){
      _delete_job($next_job);
    }
    $datafile->delete;
  }
  $job->delete;
  return 1;
}

=back

=cut


1;
