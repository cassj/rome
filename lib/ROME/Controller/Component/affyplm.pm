package ROME::Controller::Component::affyplm;

use strict;
use warnings;
use base 'Catalyst::Controller';
use ROME::Processor;
use ROME::Constraints;

=head1 NAME

ROME::Controller::Component::affyplm - ROME Component Controller

=head1 DESCRIPTION

This is a Catalyst controller for a ROME component.

=head1 METHODS

=over2

=cut


our $VERSION = "0.0.1";

### PROCESS METHODS ###

### START PROCESS nuse ###

=item nuse
  passes the template for the nuse process to the view

=cut
sub nuse :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/affyplm/nuse';

}

#parameter validation for nuse_queue
sub _validate_nuse :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw()],	
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
					    },
		     };
 
 $c->form($dfv_profile);
}

=item nuse_queue

  Ajax action to which the component/affyplm/nuse  form submits

=cut

sub nuse_queue :Path('nuse/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_nuse')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "nuse",
              component_name => "affyplm",
              component_version =>"0.0.1"
       });
       die "process NUSE not found" unless $process;

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

### END PROCESS nuse ###




### START PROCESS rle ###

=item rle
  passes the template for the rle process to the view

=cut
sub rle :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/affyplm/rle';

}

#parameter validation for rle_queue
sub _validate_rle :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw()],	
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
					    },
		     };
 
 $c->form($dfv_profile);
}

=item rle_queue

  Ajax action to which the component/affyplm/rle  form submits

=cut

sub rle_queue :Path('rle/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_rle')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "rle",
              component_name => "affyplm",
              component_version =>"0.0.1"
       });
       die "process RLE not found" unless $process;

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

### END PROCESS rle ###




### START PROCESS chip_image ###

=item chip_image
  passes the template for the chip_image process to the view

=cut
sub chip_image :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/affyplm/chip_image';

}

#parameter validation for chip_image_queue
sub _validate_chip_image :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(type selected_outcomes )],	
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
		        type => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::is_one_of(qw/weights residuals/)
		        ],
		        selected_outcomes => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::outcome_exists($c)
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item chip_image_queue

  Ajax action to which the component/affyplm/chip_image  form submits

=cut

sub chip_image_queue :Path('chip_image/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_chip_image')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "chip_image",
              component_name => "affyplm",
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

### END PROCESS chip_image ###




### START PROCESS make_plm ###

=item make_plm
  passes the template for the make_plm process to the view

=cut
sub make_plm :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/affyplm/make_plm';

}

#parameter validation for make_plm_queue
sub _validate_make_plm :Private{
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

=item make_plm_queue

  Ajax action to which the component/affyplm/make_plm  form submits

=cut

sub make_plm_queue :Path('make_plm/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_make_plm')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "make_plm",
              component_name => "affyplm",
              component_version =>"0.0.1"
       });
       die "process Make PLM not found" unless $process;

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

### END PROCESS make_plm ###


 





=back

=head1 AUTHOR

caroline johnston
=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
