package ROMEDB::ContVarWorkgroup;

use base qw/DBIx::Class/;


=head1 NAME
    
    ROMEDB::ContVarorkgroup
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'cont_var_workgroup' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('cont_var_workgroup');
__PACKAGE__->add_columns(qw/cont_var_name cont_var_owner workgroup_name/);
__PACKAGE__->set_primary_key(qw/cont_var_name cont_var_owner workgroup_name/);


=head1 RELATIONSHIP ACCESSORS

=over 2

=item cont_var

    The continuous variable which is being shared. 

=cut

__PACKAGE__->belongs_to(cont_var => 'ROMEDB::ContVar', 
			{'foreign.name'  => 'self.cont_var_name',
			 'foreign.owner' => 'self.cont_var_owner'
			});

=item workgroup

  The workgroup with which the variable is being shared.

=cut

__PACKAGE__->belongs_to(workgroup => 'ROMEDB::Workgroup', {'foreign.name' => 'self.workgroup_name'});


=back

=cut

1;

