package ROMEDB::FactorExperiment;

use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('factor_experiment');
__PACKAGE__->add_columns(qw/factor_name factor_owner experiment_name experiment_owner/);
__PACKAGE__->set_primary_key(qw/factor_name factor_owner experiment_name experiment_owner/);


__PACKAGE__->belongs_to(experiment => 'ROMEDB::Experiment',{'foreign.name' => 'self.experiment_name',
							    'foreign.owner'=> 'self.experiment_owner'});    
__PACKAGE__->belongs_to(factor => 'ROMEDB::Factor',{'foreign.name' => 'self.factor_name',
						    'foreign.owner'=> 'self.factor_owner'});    

=head1 NAME
    
    ROMEDB::FactorExperiment
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'factor_experiment' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table for the many_to_many relationships defined in 
    ROMEDB::Experiment and ROMEDB::Factor. You may wish to use the accessors
    from these classes, rather than accessing the linking table directly.
 
=head1 ACCESSORS
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item factor

    The factor we are linking to an experiment
    Expands to an object of class ROMEDB::Factor

=item experiment

    The experiment to which we are linking a factor
    Expands to an object of class ROMEDB::Experiment

=back

=cut

 
1;
