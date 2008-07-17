package ROMEDB::DatafilePending;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::DatafilePending 

=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datafile_pending' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut



__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('datafile_pending');
__PACKAGE__->add_columns(qw/datafile_name datafile_experiment_name datafile_experiment_owner/);
__PACKAGE__->set_primary_key(qw/datafile_name datafile_experiment_name datafile_experiment_owner/);


=head1 METHODS

=head1 Relationship Methods

=over 2

=item datafile

    The datafile this actually refers to
    Expands to an object of class ROMEDB::Datafile

=back

=cut

__PACKAGE__->belongs_to(datafile => 'ROMEDB::Datafile', {'foreign.name'             => 'self.datafile_name',
							 'foreign.experiment_name'  => 'self.datafile_experiment_name',
							 'foreign.experiment_owner' => 'self.datafile_experiment_owner'});

 
1;
