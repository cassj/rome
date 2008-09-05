package ROME::Controller::Component::affy_mva_pairs;

use strict;
use warnings;
use base 'Catalyst::Controller';
use ROME::Processor;
use ROME::Constraints;

=head1 NAME

ROME::Controller::Component::affy_mva_pairs - ROME Component Controller

=head1 DESCRIPTION

This is a Catalyst controller for a ROME component.

=head1 METHODS

=over2

=cut


our $VERSION = "0.0.1";

### PROCESS METHODS ###

### START PROCESS mva_pairs ###

=item mva_pairs
  passes the template for the mva_pairs process to the view

=cut
sub mva_pairs :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/affy_mva_pairs/mva_pairs';

}

#parameter validation for mva_pairs_queue
sub _validate_mva_pairs :Private{
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
                                               'not_is_single'      => 'Process needs at least two outcomes',
 					      },
			      },
		      filters => ['trim'],
		      missing_optional_valid => 1,    
		      constraint_methods => {
		        selected_outcomes => [
		           ROME::Constraints::outcome_exists($c),
			   ROME::Constraints::not_is_single,
		     ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item mva_pairs_queue

  Ajax action to which the component/affy_mva_pairs/mva_pairs  form submits

=cut

sub mva_pairs_queue :Path('mva_pairs/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_mva_pairs')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "mva_pairs",
              component_name => "affy_mva_pairs",
              component_version =>"0.0.1"
       });
       die "process MvA Pairs Plot not found" unless $process;

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

### END PROCESS mva_pairs ###


 





=back

=head1 AUTHOR

caroline johnston
=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;