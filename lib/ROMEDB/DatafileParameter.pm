package ROMEDB::DatafileParameter;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('datafile_parameter');
__PACKAGE__->add_columns(qw/datafile_name datafile_experiment_name datafile_experiment_owner value parameter/);
__PACKAGE__->set_primary_key(qw/datafile_name datafile_experiment_name datafile_experiment_owner parameter/);

#Relationships

__PACKAGE__->belongs_to(datafile => 'ROMEDB::Datafile', {'foreign.name'             => 'self.datafile_name',
							 'foreign.experiment_name'  => 'self.datafile_experiment_name',
							 'foreign.experiment_owner' => 'self.datafile_experiment_owner'});

__PACKAGE__->belongs_to(parameter => 'ROMEDB::Parameter','parameter');    

=head1 NAME
    
    ROMEDB::DatafileParameter 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datafile_parameter' 
    linking table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table which connects datafiles with the parameters used to 
    create them. The table also includes the value of the parameter for the given
    datafile.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item value
 
    The value of the parameter used for this datafile

=back
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item datafile 

    The datafile we are linking to a parameter
    Expands to an object of class ROMEDB::Datafile

=item parameter

    The parameter we are linking to a datafile
    Expands to an object of class ROMEDB::Parameter

=back

=cut

 
1;
