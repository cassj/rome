package ROME::Controller::Component::affy_chipimage;

use strict;
use warnings;
use base 'Catalyst::Controller';
use ROME::Processor;
use ROME::Constraints;

=head1 NAME

ROME::Controller::Component::affy_chipimage - ROME Component Controller

=head1 DESCRIPTION

This is a Catalyst controller for a ROME component.

=head1 METHODS

=over2

=cut


our $VERSION = "0.0.1";

### PROCESS METHODS ###

### START PROCESS chipimage ###

=item chipimage
  passes the template for the chipimage process to the view

=cut
sub chipimage :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/affy_chipimage/chipimage';

}

#parameter validation for chipimage_queue
sub _validate_chipimage :Private{
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
		           ROME::Constraints::is_single,
			   ROME::Constraints::outcome_exists($c),
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item chipimage_queue

  Ajax action to which the component/affy_chipimage/chipimage  form submits

=cut

sub chipimage_queue :Path('chipimage/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_chipimage')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "chipimage",
              component_name => "affy_chipimage",
              component_version =>"0.0.1"
       });
       die "process Chip Image not found" unless $process;

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

### END PROCESS chipimage ###


 





=back

=head1 AUTHOR

caroline johnston
=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
