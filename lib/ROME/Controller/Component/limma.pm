package ROME::Controller::Component::limma;

use strict;
use warnings;
use base 'Catalyst::Controller';
use ROME::Processor;
use ROME::Constraints;

=head1 NAME

ROME::Controller::Component::limma - ROME Component Controller

=head1 DESCRIPTION

This is a Catalyst controller for a ROME component.

=head1 METHODS

=over2

=cut


our $VERSION = "0.0.1";

### PROCESS METHODS ###



### START PROCESS test_contrasts ###

=item treatments 

 returns a hashref keyed by treatments containing the outcome
 names corresponding to those treatments

 treatment names are of the form facname_levelname.facname_levelname

 Assumes only a single datafile is selected, which should be
 true for this process.

=cut
sub treatments {
  my ($self,$c) = @_;
  my $datafile = $c->user->datafiles->next;
  my $outcomes = $datafile->outcomes;

  my $treatments = {};
  while(my $outcome = $outcomes->next){
    my $levels = $outcome->levels;
    my $treatment;
    while (my $level = $levels->next){
      if ($treatment){
	$treatment = join '.', $treatment, $level->factor->name.'_'.$level->name;
      }
      else{
	$treatment = $level->factor->name.'_'.$level->name;
      }
    }
    push @{$treatments->{$treatment}}, $outcome->name;
  }
  return $treatments;
}


=item test_contrasts
  passes the template for the test_contrasts process to the view

=cut
sub test_contrasts :Local{

  my ($self, $c) = @_;

  $c->stash->{treatments} = $self->treatments($c);
  $c->stash->{template} = 'component/limma/test_contrasts';

}

#parameter validation for test_contrasts_queue
sub _validate_test_contrasts :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(contrasts )],	
		      optional => [qw()],	
		      dependencies =>{},
		      msgs => {
			       format => '%s',
			       constraints => {
					       'is_single'          => 'Multiple values not allowed',
					       'is_number'          => 'Not a real number',
					       'is_integer'         => 'Not an integer',
					       'is_boolean'         => 'Value can only be 1 or 0',
					       'is_more_than'       => 'Value is less than the minimum allowed',
					       'is_less_than'       => 'Value is more than the maximum allowed',
					       'is_one_of'          => 'Value is not one of the defined options',
					       'allowed_chars'      => 'Invalid charcters used',
					       'allowed_chars_plus' => 'Invalid characters used',
					       'outcome_exists'     => 'Outcome not found',
					      },
			      },
		      filters => ['trim'],
		      missing_optional_valid => 1,    
		      constraint_methods => {
		        contrasts => [
				     ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item test_contrasts_queue

  Ajax action to which the component/limma/test_contrasts  form submits

=cut

sub test_contrasts_queue :Path('test_contrasts/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_test_contrasts')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "test_contrasts",
              component_name => "limma",
              component_version =>"0.0.1"
       });
       die "process Test Contrasts not found" unless $process;

       # get an appropriate processor
       my $processor = ROME::Processor->new($process->processor);
  
       # set your process in the processor
       $processor->process($process);
  
       # give the processor the current context
       $processor->context($c);

       # set the arguments for the process
       # the processor enforces all the constraints defined
       # for the process parameters when queue is called 
       # so you can just pass the form values straight through
       $processor->arguments({map {$_ => $c->request->params->{$_}} $c->form->valid});

       # create a job and put it in the job queue to be run
       $processor->queue();

       $c->stash->{status_msg} = "Process queued";
     }
     #any dfv errors are automatically inserted into the 
     #stash error_msg by the template
     return;
}

### END PROCESS test_contrasts ###




### START PROCESS limma_fit ###

=item limma_fit
  passes the template for the limma_fit process to the view

=cut
sub limma_fit :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/limma/limma_fit';
}

#parameter validation for limma_fit_queue
sub _validate_limma_fit :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(selected_outcomes )],	
		      optional => [qw()],	
		      dependencies =>{},
		      msgs => {
			       format => '%s',
			       constraints => {
					       'is_single'          => 'Multiple values not allowed',
					       'is_number'          => 'Not a real number',
					       'is_integer'         => 'Not an integer',
					       'is_boolean'         => 'Value can only be 1 or 0',
					       'is_more_than'       => 'Value is less than the minimum allowed',
					       'is_less_than'       => 'Value is more than the maximum allowed',
					       'is_one_of'          => 'Value is not one of the defined options',
					       'allowed_chars'      => 'Invalid charcters used',
					       'allowed_chars_plus' => 'Invalid characters used',
					       'outcome_exists'     => 'Outcome not found',
					      },
			      },
		      filters => ['trim'],
		      missing_optional_valid => 1,    
		      constraint_methods => {
		        selected_outcomes => [
		           ROME::Constraints::outcome_exists($c)
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item limma_fit_queue

  Ajax action to which the component/limma/limma_fit  form submits

=cut

sub limma_fit_queue :Path('limma_fit/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_limma_fit')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "limma_fit",
              component_name => "limma",
              component_version =>"0.0.1"
       });
       die "process Fit Limma Model not found" unless $process;

       # get an appropriate processor
       my $processor = ROME::Processor->new($process->processor);
  
       # set your process in the processor
       $processor->process($process);
  
       # give the processor the current context
       $processor->context($c);

       # set the arguments for the process
       # the processor enforces all the constraints defined
       # for the process parameters when queue is called 
       # so you can just pass the form values straight through
       $processor->arguments({map {$_ => $c->request->params->{$_}} $c->form->valid});

       # create a job and put it in the job queue to be run
       $processor->queue();

       $c->stash->{status_msg} = "Process queued";
     }
     #any dfv errors are automatically inserted into the 
     #stash error_msg by the template
     return;
}

### END PROCESS limma_fit ###


 





=back

=head1 AUTHOR

caroline johnston
=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
