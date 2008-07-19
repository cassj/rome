package ROMEDB::Datafile;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::Datafile 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datafile' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('datafile');


=head1 METHODS

=head1 Simple Accessors

=over 2

=item name

  The name of the experiment. 
  This must be unique within the experiment to which the datafile belongs.
  
=item description

    A user-defined description of this datafile. Optional.

=item path

   The path to the file, relative to the experiment_owner's data_dir.

=back

=cut

__PACKAGE__->add_columns(qw/name 
                            path 
                            datatype 
                            experiment_name 
                            experiment_owner 
                            status
			    job_id
			    is_root
                          /);

__PACKAGE__->set_primary_key(qw/name experiment_name experiment_owner/);


=item experiment

  The experiment to which this datafile belongs.
  Expands to an object of class ROMEDB::Experiment.

=cut

__PACKAGE__->belongs_to(experiment => 'ROMEDB::Experiment',{'foreign.name'=>'self.experiment_name',
							   'foreign.owner'=>'self.experiment_owner'});


#=item process
#
#  The process which generated this datafile
#
#=cut 
#
#__PACKAGE__->belongs_to(process=>'ROMEDB::Process', 'process');

=item job

  the job which generated this datafile
  Inflates to an object of class ROMEDB::Job

=cut

__PACKAGE__->belongs_to(job => 'ROMEDB::Job', 'job_id');


=item datatype

    The datatype of this datafile
    Expands to an object of clases ROMEDB::Datatype

=cut

__PACKAGE__->belongs_to(datatype=>'ROMEDB::Datatype', 'datatype');


=item pending

=cut

__PACKAGE__->might_have(pending=>'ROMEDB::DatafilePending', 
			{
			 'foreign.datafile_name' => 'self.name',
			 'foreign.datafile_experiment_name' => 'self.experiment_name',
			 'foreign.datafile_experiment_owner' => 'self.experiment_owner',
			});

=item selected_by

  has_many relationship
  Users who currently have this datatype selected
  An array of ROMEDB::Person objects

=cut

__PACKAGE__->has_many(datafile_selected_by=>'ROMEDB::PersonDatafile',
		      {
          'foreign.datafile_name'              => 'self.name',
	  'foreign.datafile_experiment_name'   => 'self.experiment_name',
	  'foreign.datafile_experiment_owner'  => 'self.experiment_owner',
		      });

__PACKAGE__->many_to_many(selected_by=>'datafile_selected_by','person');




=item in_datafiles
    
    has_many relationship between datafile and job representing the files used as input.
    expands to a list of ROMEDB::InDatafile objects

=cut

__PACKAGE__->has_many(in_datafiles => 'ROMEDB::InDatafile',{
                          'foreign.datafile_name' => 'self.name',
			  'foreign.datafile_experiment_name' => 'self.experiment_name',
			  'foreign.datafile_experiment_owner' => 'self.experiment_owner',
		      });

=item input_to

    Many to Many relationship between job and datafiles
    Returns the jobs to which this file is used as input
    a list of ROMEDB::Job objects

=cut

__PACKAGE__->many_to_many(input_to => 'in_datafiles', 'datafile');


#=item job_out_datafiles
#    
#    has_many relationship between job and datafile representing the files created.
#    Expands to a list of ROMEDB::OutDatafile objects
#
#=cut
#
#__PACKAGE__->has_many(job_out_datafiles => 'ROMEDB::OutDatafile',{
#                          'foreign.datafile_name' => 'self.name',
#			  'foreign.datafile_experiment_name' => 'self.experiment_name',
#			  'foreign.datagile_experiment_owner' => 'self.experiment_owner',
#		      });
#
#
#__PACKAGE__->many_to_many(out_datafiles =>'job_out_datafiles','job');



=item datafile_workgroups

  has_many relationship to the datafile_workgroup table.
  Expands to a list of ROMEDB::DatafileWorkgroup objects

=cut


__PACKAGE__->has_many(datafile_workgroups => 'ROMEDB::DatafileWorkgroup',
		      {
		       'foreign.datafile_name' => 'self.name',
		       'foreign.datafile_experiment_name' => 'self.experiment_name',
		       'foreign.datafile_experiment_owner' => 'self.experiment_owner'
		      });

=item workgroups

  many_to_many relationship to the workgroup table, mapping through
  datafile_workgroups

  The workgroups with which this datafile is shared.

  Expands to a list of class ROMEDB::Workgroup

=cut

__PACKAGE__->many_to_many(workgroups=>'datafile_workgroups', 'workgroup');

=item metadata

    Metadata (name=value pairs) associated with this datafile
    Inflates to an object of class ROMEDB::DatafileMetadata

=cut

__PACKAGE__->has_many(metadata=>'ROMEDB::DatafileMetadata', 
		      {
			  'foreign.datafile_name' => 'self.name',
			  'foreign.datafile_experiment_name' => 'self.experiment_name',
			  'foreign.datafile_experiment_owner' => 'self.experiment_owner',
		      });








=item outcome_datafiles

    A has_many relationship to the outcome_datafile mapping table
    You probably don't want to use this directly.

=item outcomes

   A many_to_many relationship with the outcomes in outcome_datafile.
   The experimental outcomes associated with this datafile 
 
=cut

__PACKAGE__->has_many(outcome_datafiles=>'ROMEDB::OutcomeDatafile',
		      {
          'foreign.datafile_name'              => 'self.name',
	  'foreign.datafile_experiment_name'   => 'self.experiment_name',
	  'foreign.datafile_experiment_owner'  => 'self.experiment_owner',
		      });

__PACKAGE__->many_to_many(outcomes=>'outcome_datafiles','outcome');







=head1 PROXY ACCESSORS

    Subclasses of Datafile have belongs_to relationships defined which create 
    proxy accessors in the Datafile class for the subclass columns. 

=over 2

=item mime_type

    The mime type of the file. This only applies to image, export
    and report files and is not guaranteed to be set.

=cut




## A ResultSource based on the Job class which only
## returns Root jobs

my $source = __PACKAGE__->result_source_instance();
my $new_source = $source->new( $source );
$new_source->source_name( 'ROMEDB::RootDatafile' );
  
# Hand in your query as a scalar reference
# It will be added as a sub-select after FROM,
# so pay attention to the surrounding brackets!
$new_source->name( \<<SQL );
( SELECT d.* FROM datafile d 
  WHERE d.is_root = 1 )
SQL


# Finally, register your new ResultSource with your Schema
ROMEDB->register_source( 'ROMEDB::RootDatafile' => $new_source );










=back

=cut


 
1;
