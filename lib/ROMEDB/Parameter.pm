package ROMEDB::Parameter;

use base qw/DBIx::Class/;


=head1 NAME
    
    ROMEDB::Parameter
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'parameter' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
   

=cut


__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('parameter');


=head1 METHODS

=over 2

=item name

    The parameter's name. Unique within a process.


=item description

  An optional description

=cut


__PACKAGE__->add_columns(qw/name display_name process_name process_component_name process_component_version description optional default_value form_element_type min_value max_value is_multiple position fieldset/);
__PACKAGE__->set_primary_key(qw/name process_name process_component_name process_component_version/);

 

=item process

  The process to which this parameter belongs.
  Expands to an object of class ROMEDB::Process


=cut

__PACKAGE__->belongs_to(process=>'ROMEDB::Process', 
			{
			    'foreign.name' => 'self.process_name',
			    'foreign.component_name' => 'self.process_component_name',
			    'foreign.component_version' => 'self.process_component_version',
			});


=item fieldset

  The fieldset to which this parameter belongs

=cut

__PACKAGE__->belongs_to(fieldset=>'ROMEDB::Fieldset',
			{
			 'foreign.name' => 'self.fieldset',
			 'foreign.process_name' => 'self.process_name',
			 'foreign.process_component_name' => 'self.process_component_name',
			 'foreign.process_component_version' => 'self.process_component_version',
			} );

=item arguments

  has_many relationship to the argument table
  Actual Argument values of this parameter

=cut

__PACKAGE__->has_many(arguments=> 'ROMEDB::Argument',
		      {
			  'foreign.parameter_name' => 'self.name',
			  'foreign.parameter_process_name' => 'self.process_name',
			  'foreign.parameter_process_component_name' => 'self.process_component_name',
			  'foreign.parameter_process_component_version' => 'self.process_component_version',
		      });


=item allowed_values

  has_many relationship to the parameter_allowed_values table
  The allowed values of this parameter.
  Not defined for all parameter types.
  This information is only really used for generation of the process form
  parameter constraint checks are defined in the controller

=cut

__PACKAGE__->has_many(allowed_values=>'ROMEDB::ParameterAllowedValue', 
			{
			    'foreign.parameter_name' => 'self.name',
			    'foreign.parameter_process_name' => 'self.process_name',
			    'foreign.parameter_process_component_name'=> 'self.process_component_name',
			    'foreign.parameter_process_component_version' => 'self.process_component_version',
			});



=back

=cut


1;
