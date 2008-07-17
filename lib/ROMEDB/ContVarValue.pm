package ROMEDB::ContVarValue;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('cont_var_value');
__PACKAGE__->add_columns(qw/cont_var_name cont_var_owner outcome_name outcome_experiment_name outcome_experiment_owner value/);
__PACKAGE__->set_primary_key(qw/cont_var_name cont_var_owner outcome_name outcome_experiment_name outcome_experiment_owner/);


=head1 NAME
    
    ROMEDB::ContVarValue
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'cont_var_value' table of the ROME database
   
    A specific value of a continuous independent variable, associated with a given 
    experimental outcome
 
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item id
 
    Unique numerical ID. Primary Key.

=back
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item cont_var

    The continuous variable of which this is a value
    Expands to an object of class ROMEDB::ContVar

=cut

__PACKAGE__->belongs_to(cont_var => 'ROMEDB::ContVar', {'foreign.name'=>'self.cont_var_name',
							'foreign.owner' => 'self.cont_var_owner',
						       });



=item outcome

    The experimental outcome which was generated using this value

=cut


__PACKAGE__->belongs_to(outcome => 'ROMEDB::Outcome', { 'foreign.name' => 'self.outcome_name',
							'foreign.experiment_name' => 'self.outcome_experiment_name',
							'foreign.experiment_owner'=> 'self.outcome_experiment_owner'
						      });




=back

=cut

 
1;
