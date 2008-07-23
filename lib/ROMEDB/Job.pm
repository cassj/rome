package ROMEDB::Job;

use base qw/DBIx::Class/;

=head1 NAME
  
  ROMEDB::Job

=head1 DESCRIPTION 

      For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    A ROME job

=cut


__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('job');


=head1 METHODS

=over 2

=item id
 
    Unique numerical ID. Primary Key.


=item owner

    The user who owns this job  
    Expands to an instance of ROMEDB::Person
    
=item experiment
    
    The experiment to which this job belongs
    Expands to an instance of ROMEDB::Experiment

=item process

    The process used to generate this job
    Expands to an instance of ROMEDB::Process

=item log

    BLOB of the log file for this experiment.

=item completed

    A boolean value indicating whether the job has been
    successfully completed 

=item script
    
    The full path to the script to be run.

=item queued

    A might_have relationship to the queue table.
    Expands to a ROMEDB::Queue object.

=item is_root

    A boolean value indicating whether the job is the root of
    a workflow. True if this job has no input files. 

=cut


__PACKAGE__->add_columns(qw/id owner experiment_name experiment_owner process_name process_component_name process_component_version log completed script is_root/);
__PACKAGE__->set_primary_key(qw/id/);

__PACKAGE__->belongs_to(owner => 'ROMEDB::Person', 'owner');
__PACKAGE__->belongs_to(process => 'ROMEDB::Process', 
			{
			    'foreign.name' => 'self.process_name',
			    'foreign.component_name' => 'self.process_component_name',
			    'foreign.component_version' => 'self.process_component_version'
			});
__PACKAGE__->belongs_to(experiment => 'ROMEDB::Experiment', {'foreign.name'=>'self.experiment_name', 
			                                     'foreign.owner'=> 'self.experiment_owner'});

__PACKAGE__->might_have(queued=>'ROMEDB::Queue', {'foreign.jid'=>'self.id'});





=item job_in_datafiles
    
    has_many relationship between job and datafile representing the files used as input.
    expands to a list of ROMEDB::InDatafile objects


=item in_datafiles

    Many to Many relationship between job and datafiles
    Returns the files used as input to this job as 
    a list of ROMEDB::Datafile objects

=cut



__PACKAGE__->has_many(job_in_datafiles => 'ROMEDB::InDatafile', {
                          'foreign.jid' => 'self.id',
		      });

__PACKAGE__->many_to_many(in_datafiles => 'job_in_datafiles', 'datafile');


=item out_datafiles

  has_many to the datafile table. 
  Datafiles this job creates

=cut

__PACKAGE__->has_many(out_datafiles=>'ROMEDB::Datafile', {'foreign.job_id' => 'self.id'});




=item arguments

  has_many relationship to the argument table

=cut



__PACKAGE__->has_many(arguments => 'ROMEDB::Argument', {
                          'foreign.jid' => 'self.id',
		      });



#really? do i need this? 

## A ResultSource based on the Job class which only
## returns Root jobs

my $source = __PACKAGE__->result_source_instance();
my $new_source = $source->new( $source );
$new_source->source_name( 'ROMEDB::RootJob' );
  
# Hand in your query as a scalar reference
# It will be added as a sub-select after FROM,
# so pay attention to the surrounding brackets!
$new_source->name( \<<SQL );
( SELECT j.* FROM job j 
  WHERE j.is_root = 1 )
SQL


#hacky fix to sort out DBIC's lookup tables.
@ROMEDB::RootJob::ISA = ('ROMEDB::Job');
$new_source->result_class('ROMEDB::RootJob');

# Finally, register your new ResultSource with your Schema
ROMEDB->register_source( 'ROMEDB::RootJob' => $new_source );



=back

=cut
 
1;
