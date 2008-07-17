package ROMEDB::Outcome;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::Outcome
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'outcome' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('outcome');


=head1 METHODS

=head1 Simple Accessors

=over 2

=item name
 
    Name for this outcome, not necessarily unique.

=item experiment_name, experiment_owner

    Foreign key to experiment. Along with name, these fields
    comprise the primary key. An outcome name must be unique
    within a given experiment.

=item description

    Optional description for this outcome.

=cut

__PACKAGE__->add_columns(qw/
                            name
                            display_name
                            experiment_name
                            experiment_owner
                            description 
                          /);

__PACKAGE__->set_primary_key(qw/name experiment_name experiment_owner/);



=item experiment
    
    A belongs_to relationship to the experiment table.

=cut

__PACKAGE__->belongs_to(experiment=>'ROMEDB::Experiment',
			            {'foreign.name'  => 'self.experiment_name',
				     'foreign.owner' => 'self.experiment_owner'
				    });



=item outcome_datafile

   A has_many relationship to the outcome_datafile mapping table. 
   You probably don't want to use this directly

=item datafiles

  A many to many relationship with the datafiles from outcome_datafiles. 

=cut

__PACKAGE__->has_many(outcome_datafiles=>'ROMEDB::OutcomeDatafile',{
                        'foreign.outcome_name'=> 'self.name',
			'foreign.outcome_experiment_name'=> 'self.experiment_name',
			'foreign.outcome_experiment_owner'=> 'self.experiment_owner',
		      });

__PACKAGE__->many_to_many(datafiles=>'outcome_datafiles','datafile');


=item outcome_levels

   A has_many relationship to the outcome_level mapping table.
   You probably don't want to use this directly.

=item levels

   A many to many relationship with the levels from outcome_level

=cut

__PACKAGE__->has_many(outcome_levels=>'ROMEDB::OutcomeLevel', {
                         'foreign.outcome_name'=>'self.name',
			 'foreign.outcome_experiment_name'=>'self.experiment_name',
			 'foreign.outcome_experiment_owner'=>'self.experiment_owner',
		      });

__PACKAGE__->many_to_many(levels=>'outcome_levels', 'level');



=item values

  A has_many relationship to the cont_var_value table,

  The specific values of continuous variables used to generate this outcome.

=cut

__PACKAGE__->has_many(values => 'ROMEDB::ContVarValue', 
		      {
			  'foreign.outcome_name' => 'self.name',
			  'foreign.outcome_experiment_name' => 'self.experiment_name',
			  'foreign.outcome_experiment_owner' => 'self.experiment_owner'
		      });


=back

=cut


1;
