package ROMEDB::Fieldset;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::Fieldset
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'fieldset' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly. 

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('fieldset');


=head1 METHODS

=over 2

=item name

  Name for this fieldset

=item process_name

  Name of the process to which this fieldset belongs

=item process_component_name

  Name of the component to which that process belongs

=item process_component_version

  And its version number

=item legend

  Optional text for the fieldset legend

=item position

  Integer position for this fieldset. 
  Lower numbers appear earlier on the page
  If two fieldsets in the same process have the same position 
  then they are sorted by alphabetical order on their display name

=cut

__PACKAGE__->add_columns(qw/name process_name process_component_name process_component_version legend position toggle/);
__PACKAGE__->set_primary_key(qw/name process_name process_component_name process_component_version/);



=item process

  The process to which this fieldset belongs.
  Expands to an object of class ROMEDB::Process


=cut

__PACKAGE__->belongs_to(process=>'ROMEDB::Process', 
			{
			    'foreign.name' => 'self.process_name',
			    'foreign.component_name' => 'self.process_component_name',
			    'foreign.component_version' => 'self.process_component_version',
			});


=item parameters
  
  The parameters in this fieldset

=cut
__PACKAGE__->has_many(parameters=>'ROMEDB::Parameter',
		      {
		       'foreign.fieldset'=>'self.name',
                       'foreign.process_name' => 'self.process_name',
		       'foreign.process_component_name' => 'self.process_component_name',
		       'foreign.process_component_version' => 'self.process_component_version',
		      },
		      { order_by => 'position'}
    );



1;
