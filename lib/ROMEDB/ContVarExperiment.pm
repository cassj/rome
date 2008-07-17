package ROMEDB::ContVarExperiment;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('cont_var_experiment');
__PACKAGE__->add_columns(qw/cont_var_name cont_var_owner experiment_name experiment_owner/);
__PACKAGE__->set_primary_key(qw/cont_var_name cont_var_owner experiment_name experiment_owner/);

#Relationships
__PACKAGE__->belongs_to(cont_var => 'ROMEDB::ContVar', {'foreign.name'=>'self.cont_var_name', 
							'foreign.owner'=>'self.cont_var_owner'});
__PACKAGE__->belongs_to(experiment => 'ROMEDB::Experiment',{'foreign.name' => 'self.experiment_name',
							    'foreign.owner'=> 'self.experiment_owner'});    


=head1 NAME
    
    ROMEDB::ContVarExperiment

=head1 DESCRIPTION
    
    DBIC object representing a row in the 'cont_var_experiment' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table for the many_to_many relationships defined in 
    ROMEDB::Experiment and ROMEDB::ContVar. You may wish to use the accessors
    from these classes, rather than accessing the linking table directly.

=head1 ACCESSORS

=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item cont_var

    The factor we are linking to an experiment
    Expands to an object of class ROMEDB::Factor

=item experiment

    The experiment to which we are linking a factor
    Expands to an object of class ROMEDB::Experiment

=back

=cut

1;
