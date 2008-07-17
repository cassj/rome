package ROMEDB::FactorWorkgroup;

use base qw/DBIx::Class/;


=head1 NAME
    
    ROMEDB::FactorWorkgroup
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'factor_workgroup' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('factor_workgroup');
__PACKAGE__->add_columns(qw/factor_name factor_owner workgroup_name/);
__PACKAGE__->set_primary_key(qw/factor_name factor_owner workgroup_name/);


=head1 RELATIONSHIP ACCESSORS

=over 2

=item factor 

    The factor which is being shared. 

=cut

__PACKAGE__->belongs_to(factor => 'ROMEDB::Factor', 
			{'foreign.name'  => 'self.factor_name',
			 'foreign.owner' => 'self.factor_owner'
			});

=item workgroup

  The workgroup with which the factor is being shared.

=cut

__PACKAGE__->belongs_to(workgroup => 'ROMEDB::Workgroup', {'foreign.name' => 'self.workgroup_name'});


=back

=cut

1;

