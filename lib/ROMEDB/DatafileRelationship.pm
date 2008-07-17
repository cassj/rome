package ROMEDB::DatafileRelationship;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('datafile_relationship');

__PACKAGE__->add_columns(qw/
                            parent_datafile_name 
                            parent_datafile_experiment_name 
                            parent_datafile_experiment_owner 
                            child_datafile_name
                            child_datafile_experiment_name
                            child_datafile_experiment_owner
                           /);

__PACKAGE__->set_primary_key(qw/
                            parent_datafile_name 
                            parent_datafile_experiment_name 
                            parent_datafile_experiment_owner 
                            child_datafile_name
                            child_datafile_experiment_name
                            child_datafile_experiment_owner
/);

#Relationships

__PACKAGE__->belongs_to(parent  => 'ROMEDB::Datafile', {'foreign.name'             => 'self.parent_datafile_name',
							'foreign.experiment_name'  => 'self.parent_datafile_experiment_name',
							'foreign.experiment_owner' => 'self.parent_datafile_experiment_owner'});
__PACKAGE__->belongs_to(child => 'ROMEDB::Datafile', {'foreign.name'             => 'self.child_datafile_name',
						      'foreign.experiment_name'  => 'self.child_datafile_experiment_name',
						      'foreign.experiment_owner' => 'self.child_datafile_experiment_owner'});


=head1 NAME
    
    ROMEDB::DatafileRelationship 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datafile_relationship' 
    linking table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table. The datafile class defines parents and children
    many_to_many relationships through this link. You may wish to use the many_to_many
    relationships, rather than using the link table directly.
 
=head1 ACCESSORS
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item parent 

    The datafile which was used to create the other datafile in the relationship
    Expands to an object of class ROMEDB::Datafile

=item child

    The datafile which was created from the other datafile in the relationship
    Expands to an object of class ROMEDB::Datafile

=back

=cut

 
1;
