package ROMEDB::DatafileWorkgroup;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::DatafileWorkgroup
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datafile_workgroup' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table used for the many_to_many relationship between the 
    person and workgroup tables. You probably want to access this table indirectly
    via these methods defined in ROMDB::Datafile and ROMEDB::Workgroup.

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('datafile_workgroup');
__PACKAGE__->add_columns(qw/datafile_name datafile_experiment_name datafile_experiment_owner workgroup/);
__PACKAGE__->set_primary_key(qw/datafile_name datafile_experiment_name datafile_experiment_owner workgroup/);


=head1 RELATIONSHIP ACCESSORS

=head1 belongs_to accessors

=over 2

=item datafile

    The datafile being shared with a workgroup
    Expands to an object of class ROMEDB::Person

=item workgroup

    The workgroup to which a person is being assigned
    Expands to an object of class ROMEDB::Workgroup

=back

=cut


__PACKAGE__->belongs_to(datafile => 'ROMEDB::Datafile', {'foreign.name'             => 'self.datafile_name',
							 'foreign.experiment_name'  => 'self.datafile_experiment_name',
							 'foreign.experiment_owner' => 'self.datafile_experiment_owner'});
__PACKAGE__->belongs_to(workgroup => 'ROMEDB::Workgroup','workgroup');    

 
1;
