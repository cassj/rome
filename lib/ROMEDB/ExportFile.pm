package ROMEDB::ExportFile;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('export_file');
__PACKAGE__->add_columns(qw/id datafile_name datafile_experiment_name datafile_experiment_owner mime_type/);
__PACKAGE__->set_primary_key(qw/id/);

#Relationships
__PACKAGE__->belongs_to(id => 'ROMEDB::Datafile',
			{'foreign.name' => 'self.datafile_name',
			 'foreign.experiment_name' => 'self.datafile_experiment_name',
			 'foreign.exeriment_owner' => 'self.datafile_experiment_owner'}, 
			{ proxy => [ qw/ mime_type
				       / ] });

=head1 NAME
    
    ROMEDB::ExportFile
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'ExportFile' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    ExportFile is just an extension of the Datafile table. 
    We define a belongs_to relationship here which sets proxy methods for the export_file
    table's columns in the datafile table, so in most cases, you probably want to access
    this class indirectly via ROMEDB::Datafile.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item id
 
    Unique numerical ID. 
    Primary Key. 
    Foreign key linking this table to datafile(id)

=item href

    The location from which the exported file can be downloaded.

=back
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item mime_type

   The mime type of this file.
   Not guaranteed to be set

=back
    

=cut

 
1;
