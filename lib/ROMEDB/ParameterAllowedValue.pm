package ROMEDB::ParameterAllowedValue;

use base qw/DBIx::Class/;


=head1 NAME
    
    ROMEDB::ParameterAllowedValue
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'parameter_allowed_value' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
   

=cut


__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('parameter_allowed_value');


=head1 METHODS

=over 2

=item value

  The allowed value

=cut

__PACKAGE__->add_columns(qw/parameter_name parameter_process_name parameter_process_component_name parameter_process_component_version value/);
__PACKAGE__->set_primary_key(qw/parameter_name parameter_process_name parameter_process_component_name parameter_process_component_version/);

 

=item parameter

  The parameter for which this value is allowed
  Expands to an object of class ROMEDB::Parameter


=cut

__PACKAGE__->belongs_to(process=>'ROMEDB::Parameter', 
			{
			    'foreign.name' => 'self.parameter_name',
			    'foreign.process_name' => 'self.parameter_process_name',
			    'foreign.process_component_name'=> 'self.parameter_process_component_name',
			    'foreign.process_component_version' => 'self.parameter_process_component_version',
			});

=back

=cut


1;
