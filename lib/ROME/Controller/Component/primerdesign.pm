package ROME::Controller::Component::primerdesign;

use strict;
use warnings;
use base 'Catalyst::Controller';
use ROME::Processor;
use ROME::Constraints;

=head1 NAME

ROME::Controller::Component::primerdesign - ROME Component Controller

=head1 DESCRIPTION

This is a Catalyst controller for a ROME component.

=head1 METHODS

=over2

=cut


our $VERSION = "0.0.1";

### PROCESS METHODS ###

### START PROCESS tiling_primers ###

=item tiling_primers
  passes the template for the tiling_primers process to the view

=cut
sub tiling_primers :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/primerdesign/tiling_primers';

}

#parameter validation for tiling_primers_queue
sub _validate_tiling_primers :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw()],	
		      optional => [qw(included_region_start included_region_length)],	
		      dependencies =>{
				     },
		      dependency_groups => {
					    included_region_group => [qw (included_region_start included_region_length)]
					   },
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
					       'irl_length'         => 'Included region must be at least as long as the optimum product length'
 					      },
			      },
		      filters => ['trim'],
		      missing_optional_valid => 1,    
		      constraint_methods => {
					     included_region_start => [
								       ROME::Constraints::is_single,
								       ROME::Constraints::is_integer,
								       ROME::Constraints::is_more_than(0)
								      ],
					     included_region_length => [
								     ROME::Constraints::is_single,
								     ROME::Constraints::is_integer,
								     sub {
								       my $dfv = shift;
								       $dfv->name_this('irl_length');
								       my $val = $dfv->get_current_constraint_value();
								       my $data = $dfv->get_filtered_data;
								       return $val >= $data->{product_opt_size} ? 1:0;
								     }
								    ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item tiling_primers_queue

  Ajax action to which the component/primerdesign/tiling_primers  form submits

=cut

sub tiling_primers_queue :Path('tiling_primers/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_tiling_primers')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "tiling_primers",
              component_name => "primerdesign",
              component_version =>"0.0.1"
       });
       die "process Tiling Primers not found" unless $process;

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

### END PROCESS tiling_primers ###




### START PROCESS single_primer_pair ###

=item single_primer_pair
  passes the template for the single_primer_pair process to the view

=cut
sub single_primer_pair :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/primerdesign/single_primer_pair';

}

#parameter validation for single_primer_pair_queue
sub _validate_single_primer_pair :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		     required => [qw()],	
		     optional => [qw()],	
		     dependencies =>{},
		     dependency_groups => {
					   included_region_group => [qw (included_region_start included_region_length)]
					  },
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
					       'irl_length'         => 'Included region must be at least as long as the optimum product length'
					      },
			      },
		      filters => ['trim'],
		      missing_optional_valid => 1,    
		      constraint_methods => {
					     included_region_start => [
								       ROME::Constraints::is_single,
								       ROME::Constraints::is_integer,
								       ROME::Constraints::is_more_than(0)
								      ],
					     included_region_length => [
									ROME::Constraints::is_single,
									ROME::Constraints::is_integer,
									sub {
									  my $dfv = shift;
									  $dfv->name_this('irl_length');
									  my $val = $dfv->get_current_constraint_value();
									  my $data = $dfv->get_filtered_data;
									  return $val >= $data->{product_opt_size} ? 1:0;
									}
								    ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item single_primer_pair_queue

  Ajax action to which the component/primerdesign/single_primer_pair  form submits

=cut

sub single_primer_pair_queue :Path('single_primer_pair/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_single_primer_pair')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "single_primer_pair",
              component_name => "primerdesign",
              component_version =>"0.0.1"
       });
       die "process Single Primer Pair not found" unless $process;

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

### END PROCESS single_primer_pair ###


 





=back

=head1 AUTHOR

caroline johnston
=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
