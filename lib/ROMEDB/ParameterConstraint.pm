package ROMEDB::ParameterConstraint;

use base qw/DBIx::Class/;


=head1 NAME
    
    ROMEDB::ParameterConstraint
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'parameter_constraint' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    The inforamtion in this table is used by ROME to build Data::FormValidator profiles for 
    the parameters of a process
   

=cut


__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('parameter_constraint');


=head1 METHODS

=head1 Accessors

=over 2

=item constraint_name

    The name of the constraint


=item constraint_sub

   A string which can be 'eval'ed in perl to give a sub which
   can be handed to Data::FormValidator

=back

=cut


__PACKAGE__->add_columns(qw/parameter_name parameter_process_name parameter_process_component_name parameter_process_component_version constraint_name constraint_sub constraint_error_msg/);
__PACKAGE__->set_primary_key(qw/parameter_name parameter_process_name parameter_process_component_name parameter_process_component_version constraint_name/);

 

=head1 Relationship Accessors

=over 2

=item parameter

  The parameter to which this constraint refers
  Expands to an object of class ROMEDB::Parameter



=cut

__PACKAGE__->belongs_to(parameter=>'ROMEDB::Parameter', 
			{'foreign.name'=> 'self.parameter_name',
			 'foreign.process_name' => 'self.parameter_process_name',
			 'foreign.process_component_name' => 'self.parameter_process_component_name',
			 'foreign.process_component_version' => 'self.parameter_process_component_version',
			});




=back

=cut


1;
