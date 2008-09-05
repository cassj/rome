package ROME::Controller::Component::ensembl;

use strict;
use warnings;
use base 'Catalyst::Controller';
use ROME::Processor;
use ROME::Constraints;

use Bio::EnsEMBL::Registry;

=head1 NAME

ROME::Controller::Component::ensembl - ROME Component Controller

=head1 DESCRIPTION

This is a Catalyst controller for a ROME component.

=head1 METHODS

=over2

=cut


our $VERSION = "0.0.1";

#set some defaults for ensembl DB connection settings
sub auto :Private{
  my ($self,$c) = @_;

  $c->{ensembl}->{db}->{host} = 'ensembldb.ensembl.org' unless $c->{ensembl}->{db}->{host};
  $c->{ensembl}->{db}->{user} = 'anonymous' unless $c->{ensembl}->{db}->{user};

  return 1;
}


### PROCESS METHODS ###

### START PROCESS ensembl2bioseqlite ###

=item ensembl2bioseqlite
  passes the template for the ensembl2bioseqlite process to the view

=cut
sub ensembl2bioseqlite :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/ensembl2bioseqlite';

}

#parameter validation for ensembl2bioseqlite_queue
sub _validate_ensembl2bioseqlite :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw()],	
		      optional => [qw(5prime_pad 3prime_pad 5prime_pad 3prime_pad )],	
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
		        '5prime_pad' => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_less_than(5000)
		        ],
		        '3prime_pad' => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_less_than(5000)
		        ],

					    },
		     };
 
 $c->form($dfv_profile);
}

=item ensembl2bioseqlite_queue

  Ajax action to which the component/ensembl/ensembl2bioseqlite  form submits

=cut

sub ensembl2bioseqlite_queue :Path('ensembl2bioseqlite/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_ensembl2bioseqlite')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "ensembl2bioseqlite",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Ensembl2BioSeqLite not found" unless $process;

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

### END PROCESS ensembl2bioseqlite ###




### START PROCESS ensembl2bioseq ###

=item ensembl2bioseq
  passes the template for the ensembl2bioseq process to the view

=cut
sub ensembl2bioseq :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/ensembl2bioseq';

}

#parameter validation for ensembl2bioseq_queue
sub _validate_ensembl2bioseq :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw()],	
		      optional => [qw(5prime_pad 3prime_pad )],	
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
		        '5prime_pad' => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_less_than(5000)
		        ],
		        '3prime_pad' => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_less_than(5000)
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item ensembl2bioseq_queue

  Ajax action to which the component/ensembl/ensembl2bioseq  form submits

=cut

sub ensembl2bioseq_queue :Path('ensembl2bioseq/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_ensembl2bioseq')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "ensembl2bioseq",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Ensembl2BioSeq not found" unless $process;

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

### END PROCESS ensembl2bioseq ###




### START PROCESS retrieve_slice ###

=item retrieve_slice
  passes the template for the retrieve_slice process to the view

=cut
sub retrieve_slice :Local{

  my ($self, $c) = @_;
  
  #our template needs the species data
  $c->stash->{ensembl_species} = $c->forward('_ensembl_species');
  $c->stash->{template} = 'component/ensembl/retrieve_slice';

}

=item _ensembl_species

  A private action which returns a list of ensembl species
  available in the core databases

=cut

sub _ensembl_species :Private{
  my ($self, $c, $force_reload) = @_;
  
  if ( ! defined($self->{ensembl_species} ) || $force_reload){

    my $registry = 'Bio::EnsEMBL::Registry';
    $registry->load_registry_from_db(
				     -host => $c->{ensembl}->{db}->{host},
				     -user => $c->{ensembl}->{db}->{user},
				    );

    my $dba = $registry->get_all_DBAdaptors;
    my @species;
    foreach (@$dba){
      if ($_->group eq 'core')
	{
	  push @species, $_->species;
	}

    }
    $self->{ensembl_species} = [ sort {$a cmp $b} @species ];
  }

  return $self->{ensembl_species};

}

#parameter validation for retrieve_slice_queue
sub _validate_retrieve_slice :Private{
  my ($self, $c) = @_;

  #get the available species
  my $species = $c->forward('_ensembl_species');
  my $dfv_profile = {
		      required => [qw(end start chr ensembl_species )],	
		      optional => [qw(ensembl_genome_build )],	
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
		        end => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_more_than(1)
		        ],
		        start => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_more_than(1)
		        ],
		        chr => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer,
		           ROME::Constraints::is_more_than(1)
		        ],
		        ensembl_species => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::is_one_of(@$species),
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item retrieve_slice_queue

  Ajax action to which the component/ensembl/retrieve_slice  form submits

=cut

sub retrieve_slice_queue :Path('retrieve_slice/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_retrieve_slice')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "retrieve_slice",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Retrieve Slice  not found" unless $process;

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

### END PROCESS retrieve_slice ###




### START PROCESS retrieve_peptide ###

=item retrieve_peptide
  passes the template for the retrieve_peptide process to the view

=cut
sub retrieve_peptide :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/retrieve_peptide';

}

#parameter validation for retrieve_peptide_queue
sub _validate_retrieve_peptide :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(peptide_id )],	
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
		        peptide_id => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item retrieve_peptide_queue

  Ajax action to which the component/ensembl/retrieve_peptide  form submits

=cut

sub retrieve_peptide_queue :Path('retrieve_peptide/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_retrieve_peptide')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "retrieve_peptide",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Retrieve Peptide By ID not found" unless $process;

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

### END PROCESS retrieve_peptide ###




### START PROCESS retrieve_exon ###

=item retrieve_exon
  passes the template for the retrieve_exon process to the view

=cut
sub retrieve_exon :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/retrieve_exon';

}

#parameter validation for retrieve_exon_queue
sub _validate_retrieve_exon :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(exon_id )],	
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
		        exon_id => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item retrieve_exon_queue

  Ajax action to which the component/ensembl/retrieve_exon  form submits

=cut

sub retrieve_exon_queue :Path('retrieve_exon/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_retrieve_exon')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "retrieve_exon",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Retrieve Exon By ID not found" unless $process;

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

### END PROCESS retrieve_exon ###




### START PROCESS ensembl2txt ###

=item ensembl2txt
  passes the template for the ensembl2txt process to the view

=cut
sub ensembl2txt :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/ensembl2txt';

}

#parameter validation for ensembl2txt_queue
sub _validate_ensembl2txt :Private{
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

=item ensembl2txt_queue

  Ajax action to which the component/ensembl/ensembl2txt  form submits

=cut

sub ensembl2txt_queue :Path('ensembl2txt/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_ensembl2txt')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "ensembl2txt",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Ensembl to Text not found" unless $process;

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

### END PROCESS ensembl2txt ###




### START PROCESS retrieve_transcript ###

=item retrieve_transcript
  passes the template for the retrieve_transcript process to the view

=cut
sub retrieve_transcript :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/retrieve_transcript';

}

#parameter validation for retrieve_transcript_queue
sub _validate_retrieve_transcript :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(transcript_id )],	
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
		        transcript_id => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item retrieve_transcript_queue

  Ajax action to which the component/ensembl/retrieve_transcript  form submits

=cut

sub retrieve_transcript_queue :Path('retrieve_transcript/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_retrieve_transcript')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "retrieve_transcript",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Retrieve Transcript by ID not found" unless $process;

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

### END PROCESS retrieve_transcript ###




### START PROCESS ensembl_gene_report ###

=item ensembl_gene_report
  passes the template for the ensembl_gene_report process to the view

=cut
sub ensembl_gene_report :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/ensembl_gene_report';

}

#parameter validation for ensembl_gene_report_queue
sub _validate_ensembl_gene_report :Private{
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

=item ensembl_gene_report_queue

  Ajax action to which the component/ensembl/ensembl_gene_report  form submits

=cut

sub ensembl_gene_report_queue :Path('ensembl_gene_report/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_ensembl_gene_report')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "ensembl_gene_report",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process EnsemblGene Report not found" unless $process;

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

### END PROCESS ensembl_gene_report ###




### START PROCESS ensemblgene_to_bioseq ###

=item ensemblgene_to_bioseq
  passes the template for the ensemblgene_to_bioseq process to the view

=cut
sub ensemblgene_to_bioseq :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/ensemblgene_to_bioseq';

}

#parameter validation for ensemblgene_to_bioseq_queue
sub _validate_ensemblgene_to_bioseq :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw()],	
		      optional => [qw(3pad 5pad )],	
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
		        '3pad' => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer
		        ],
		        '5pad' => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_integer
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item ensemblgene_to_bioseq_queue

  Ajax action to which the component/ensembl/ensemblgene_to_bioseq  form submits

=cut

sub ensemblgene_to_bioseq_queue :Path('ensemblgene_to_bioseq/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_ensemblgene_to_bioseq')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "ensemblgene_to_bioseq",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process EnsemblGene to BioSeq not found" unless $process;

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

### END PROCESS ensemblgene_to_bioseq ###




### START PROCESS dbconnect ###

=item dbconnect
  passes the template for the dbconnect process to the view

=cut
sub dbconnect :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/dbconnect';

}

#parameter validation for dbconnect_queue
sub _validate_dbconnect :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(dbuser dbhost )],	
		      optional => [qw(ensembl_version dbpass )],	
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
		        ensembl_version => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
		           ROME::Constraints::is_number,
		           ROME::Constraints::is_more_than(1)
		        ],
		        dbpass => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus
		        ],
		        dbuser => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus
		        ],
		        dbhost => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item dbconnect_queue

  Ajax action to which the component/ensembl/dbconnect  form submits

=cut

sub dbconnect_queue :Path('dbconnect/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_dbconnect')){
    
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "dbconnect",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Connect to an Ensembl DB not found" unless $process;

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

### END PROCESS dbconnect ###




### START PROCESS retrieve_gene ###

=item retrieve_gene
  passes the template for the retrieve_gene process to the view

=cut
sub retrieve_gene :Local{

  my ($self, $c) = @_;
  $c->stash->{template} = 'component/ensembl/retrieve_gene';

}


# check the provided ID is valid.
# this requires the server to have access to the ensembl db.
# if the DB connection fails it will return true and let the 
# job script have a shot at it.

#this is working the first time we call it, but not the second time. 
#Even if we reload the page. WTF? 
sub _valid_gene_id{
  my ($self, $c) = @_;

  my $dbhost = $c->{ensembl}->{db}->{host};
  my $dbuser = $c->{ensembl}->{db}->{user};
  my $dbpass = $c->{ensembl}->{db}->{pass};

  return sub{
    my $dfv = shift;
    $dfv->name_this('valid_id');
    my $val = $dfv->get_current_constraint_value();
    my $registry = 'Bio::EnsEMBL::Registry';
    $registry->load_registry_from_db (
				      -host => $dbhost,
				      -user => $dbuser,
				      -pass => $dbpass,
				     );
    my ($species,$type) = $registry->get_species_and_object_type($val);
    return 0 unless $species;
    return 0 unless $type eq "gene";

    return 1;
  }

}

#parameter validation for retrieve_gene_queue
sub _validate_retrieve_gene :Private{
  my ($self, $c) = @_;
  my $dfv_profile = {
		      required => [qw(gene_id )],
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
					       'valid_gene_id'      => 'Not a valid EnsEMBL gene ID', 
					      },
			      },
		      filters => ['trim'],
		      missing_optional_valid => 1,    
		      constraint_methods => {
		        gene_id => [
		           ROME::Constraints::is_single,
		           ROME::Constraints::allowed_chars_plus,
			   __PACKAGE__->_valid_gene_id($c),
		        ],
					    },
		     };
 
 $c->form($dfv_profile);
}

=item retrieve_gene_queue

  Ajax action to which the component/ensembl/retrieve_gene  form submits

=cut

sub retrieve_gene_queue :Path('retrieve_gene/queue'){
    my ($self, $c) = @_;

    $c->stash->{template} = 'site/messages';
    $c->stash->{ajax} = 1;

     #check your form parameters
     if ($c->forward('_validate_retrieve_gene')){
       
       # get your process 
       my $process = $c->model('ROMEDB::Process')->find({
              name => "retrieve_gene",
              component_name => "ensembl",
              component_version =>"0.0.1"
       });
       die "process Retrieve Gene By ID not found" unless $process;

       # get an appropriate processor
       my $processor = ROME::Processor->new($process->processor);
  
       # set your process in the processor
       $processor->process($process);
  
       # give the processor the current context
       $processor->context($c);
       
       #set the arguments for the processor
       $processor->arguments({map {$_ => $c->request->params->{$_}} $c->form->valid});

       # create a job and put it in the job queue to be run
       $processor->queue();

       $c->stash->{status_msg} = "Process queued";
     }
     #any dfv errors are automatically inserted into the 
     #stash error_msg by the template
     return;
}

### END PROCESS retrieve_gene ###


 





=back

=head1 AUTHOR

caroline johnston
=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
