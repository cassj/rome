package ROMEDB::Argument;

use base qw/DBIx::Class/;


=head1 NAME
    
    ROMEDB::Argument
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'argument' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
   

=cut


__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('argument');


__PACKAGE__->add_columns(qw/jid parameter_name parameter_process_name parameter_process_component_name parameter_process_component_version value /);
__PACKAGE__->set_primary_key(qw/jid parameter_name parameter_process_name parameter_process_component_name parameter_process_component_version value/);



=head1 METHODS

=head1 Simple Accessors

=over 2

=item value

    The value of this Argument
    This will be a string representation of a perl datastructure generated
    using the Storable freeze method. 
    
=back

=cut

 

=head1 Relationship Accessors

=over 2

=item job
    
    The job to which this argument is given
    Expands to an object of class ROMEDB::Job


=item parameter

    The parameter of which this is an argument
    Expands to an object of class ROMEDB::Parameter



=cut

__PACKAGE__->belongs_to(parameter=>'ROMEDB::Parameter', {
                                          'foreign.name' => 'self.parameter_name',
					  'foreign.process_name'=>'self.parameter_process_name',
					  'foreign.process_component_name' => 'self.parameter_process_component_name',
					  'foreign.proces_component_version' => 'self.paramter_process_component_version',
			                                });

__PACKAGE__->belongs_to(job=>'ROMEDB::Job','jid');



=back

=cut


1;
