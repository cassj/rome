package ROMEDB::OutcomeContVarValue;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::OutcomeContVarValue
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'outcome_level' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    Many to many mapping table between Outcome and Level

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('outcome_level');


=head1 METHODS

=head1 Simple Accessors

=over 2

=item outcome_id

    The ID of the outcome in question

=item level_name, level_factor_name, level_factor_owner
 
    The name, factor_name and factor_owner of the level in question
    which comprise that level's 3-column primary key

=back

=cut

__PACKAGE__->add_columns(qw/
                            outcome_name
                            outcome_experiment_name
                            outcome_experiment_owner
                            level_name
                            level_factor_name
                            level_factor_owner
                          /);

__PACKAGE__->set_primary_key(qw/outcome_name outcome_experiment_name outcome_experiment_owner level_name level_factor_name level_factor_owner/);



__PACKAGE__->belongs_to(level=>'ROMEDB::Level', 
			{'foreign.name'=>'self.level_name',
			 'foreign.factor_name' => 'self.level_factor_name',
			 'foreign.factor_owner' => 'self.level_factor_owner',
			});

__PACKAGE__->belongs_to(outcome=>'ROMEDB::Outcome',
			{'foreign.name' => 'self.outcome_name',
			 'foreign.experiment_name'=>'self.outcome_experiment_name',
			 'foreign.experiment_owner' => 'self.outcome_experiment_owner'
			});



1;
