package ROMEDB::DatafileMetadata;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::DatafileMetadata
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datafile_metadata' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('datafile_metadata');


__PACKAGE__->add_columns(qw/datafile_name datafile_experiment_name datafile_experiment_owner datatype_metadata_name datatype_metadata_datatype_name value/);

__PACKAGE__->set_primary_key(qw/datafile_name datatype_metadata_name datatype_metadata_datatype_name /);


__PACKAGE__->belongs_to(datafile=>'ROMEDB::Datafile', 
			{
			 'foreign.name'=> 'self.datafile_name',
			 'foreign.experiment_name' => 'self.datafile_experiment_name',
			 'foreign.experiment_owner' => 'self.datafile_experiment_owner',
			});

__PACKAGE__->belongs_to(metadata => 'ROMEDB::DatatypeMetadata',
			{
			 'foreign.name' => 'self.datatype_metadata_name',
			 'foreign.datatype_name' => 'self.datatype_metadata_datatype_name',
			});


=head1 METHODS

=over 2

=item datafile

   The datafile to which this piece of metadata refers. 
   Expands to an object of type ROMEDB::Datafile

=item metadata

   The datatype metadata of which this metadata is a type
   Inflates to an object of type ROMEDB::DatatypeMetadata

=back

=cut



1;
