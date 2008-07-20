package ROME::Controller::Component::Test;

use strict;
use warnings;
use base 'Catalyst::Controller';
use ROME::Processor;
use ROME::Constraints;

=head1 NAME

ROME::Controller::Component::Test - ROME Component Controller

=head1 DESCRIPTION

This is a Catalyst controller for a ROME component.

=head1 METHODS

=over2

=cut


our $VERSION = "0.0.1";

### PROCESS METHODS ###

### START PROCESS foo ###

=item foo
  passes the template for the foo process to the view

=cut
sub foo :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/test/foo';

}

#parameter validation for foo_queue
sub _validate_foo :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(b a )],	
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
					      },
			      },
		      filters => ['trim'],
		      missing_optional_valid => 1,    
		      constraint_methods => {
		        b => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_less_than(11)
		        ],
		        a => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_less_than(11)
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item foo_queue

  Ajax action to which the component/test/foo  form submits

=cut

sub foo_queue :Path('foo/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;
    
    #check your form parameters
    if ($c->forward('_validate_foo')){
	
	# get your process 
	my $process = $c->model('ROMEDB::Process')->find({
	    name => "foo",
	    component_name => "test",
	    component_version =>"0.0.1"
							 });
	die "process Foo not found" unless $process;
	
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
	$processor->arguments({map {$_ => $c->request->params->{$_}} $c->form->valid} );
	
	# create a job and put it in the job queue to be run
	$processor->queue();

       $c->stash->{status_msg} = "Process queued";
     }
     #any dfv errors are automatically inserted into the 
     #stash error_msg by the template
     return;
}

### END PROCESS foo ###


 





=back

=head1 AUTHOR

caroline johnston
=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
