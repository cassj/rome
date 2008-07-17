package ROMEDB::ProcessCreates;

use base qw/DBIx::Class/;

=head1 NAME

  ROMEDB::ProcessCreates

=head1 DESCRIPTION
  
  DBIC object representing a row in the 'process_creates' table of the ROME database

  For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
  Offline utilities may wish to use this class directly.

  This is a joining table, you probably don't want to use it directly

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('process_creates');
__PACKAGE__->add_columns(qw/process_name process_component_name process_component_version datatype_name name suffix is_image is_export is_report/);
__PACKAGE__->set_primary_key(qw/process_name process_component_name process_component_version datatype_name name/);


=item process 

    The process for which we are defining acceptable datatypes
    Expands to an object of class ROMEDB::Process

=item creates 

    The datatype to be registered as acceptable input for the process
    Expands to an object of class ROMEDB::Datatype

=cut 


__PACKAGE__->belongs_to(process => 'ROMEDB::Process', 
			{
			 'foreign.name' => 'self.process_name',
			 'foreign.component_name' => 'self.process_component_name',
			 'foreign.component_version' => 'self.process_component_version'
			});


__PACKAGE__->belongs_to(creates => 'ROMEDB::Datatype','datatype_name');    

#__PACKAGE__->belongs_to(datatype => 'ROMEDB::Datatype','datatype_name');    



=back

=cut

 
1;

