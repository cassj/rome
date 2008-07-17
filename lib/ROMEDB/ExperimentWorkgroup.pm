package ROMEDB::ExperimentWorkgroup;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::ExperimentWorkgroup
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'experiment_workgroup' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table used for the many_to_many relationship between the 
    experiment and workgroup tables. You probably want to access this table indirectly
    via these methods defined in ROMDB::Experiment and ROMEDB::Workgroup.

    In fact, given that it is primarily used by the Authz::Roles::Model plugin,
    for the most part, you shouldn't need to use it at all, you should be able to use
    the methods in the model classes and have the authorization occur transparently,
    such that the results you get have already been filtered to include only those 
    to which the current user has access. 

    See rome.yml config:authorization:model for setup

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('experiment_workgroup');
__PACKAGE__->add_columns(qw/experiment_name experiment_owner workgroup/);
__PACKAGE__->set_primary_key(qw/experiment_name experiment_owner workgroup/);


=head1 RELATIONSHIP ACCESSORS

=head1 belongs_to accessors

=over 2

=item experiment

    The experiment being shared with a workgroup
    Expands to an object of class ROMEDB::Experiment

=item workgroup

    The workgroup to which a person is being assigned
    Expands to an object of class ROMEDB::Workgroup

=back

=cut


__PACKAGE__->belongs_to(experiment => 'ROMEDB::Experiment', {'foreign.name'=>'self.experiment_name',
							     'foreign.owner'=>'self.experiment_owner'});
__PACKAGE__->belongs_to(workgroup => 'ROMEDB::Workgroup','workgroup');    

 
1;
