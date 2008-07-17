package ROMEDB::PersonDatafile;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::PersonDatafile
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'person_datafile' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table used for the many_to_many relationship between the 
    person and datafile tables, representing the user's currently selected datafiles
    You probably want to access this table indirectly via these methods defined in ROMDB::Person 
    and ROMEDB::Datafile.

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('person_datafile');
__PACKAGE__->add_columns(qw/person datafile_name datafile_experiment_name datafile_experiment_owner/);
__PACKAGE__->set_primary_key(qw/person datafile_name datafile_experiment_name datafile_experiment_owner/);


=head1 RELATIONSHIP ACCESSORS

=head1 belongs_to accessors

=over 2

=item person

    The person who currently has this datafile selected.
    Expands to an object of class ROMEDB::Person

=item datafile

    The datafile selected
    Expands to an object of class ROMEDB::Datafile

=back

=cut


__PACKAGE__->belongs_to(datafile => 'ROMEDB::Datafile', {'foreign.name'             => 'self.datafile_name',
							 'foreign.experiment_name'  => 'self.datafile_experiment_name',
							 'foreign.experiment_owner' => 'self.datafile_experiment_owner'});

__PACKAGE__->belongs_to(person=> 'ROMEDB::Person','person');    

 
1;
