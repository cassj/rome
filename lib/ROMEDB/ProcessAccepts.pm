package ROMEDB::ProcessAccepts;

use base qw/DBIx::Class/;

=head1 NAME
 
  ROMEDB::ProcessAccepts

=head1 DESCRIPTION

  DBIC object representing a row in the 'process_accepts' table of the ROME database.
  
  For Catalyst, this is designed to be used through ROME::Model::ROMEDB
  Offline utilities may wish to use this class directly.

  This is a linking class for the many_to_many relationship between process
  and datatype, 'process_accepts'. This is a join table. You probably won't want
  to use it directly. 

=cut


__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('process_accepts');
__PACKAGE__->add_columns(qw/process_name process_component_name process_component_version datatype_name name/);
__PACKAGE__->set_primary_key(qw/process_name process_component_name process_component_version datatype_name name/);






=head1 METHODS

=over 2

=item required
 
    Boolean. Is this datatype required for this process?

=item process 

    The process for which we are defining acceptable datatypes
    Expands to an object of class ROMEDB::Process

=item accepts 

    The datatype to be registered as acceptable input for the process
    Expands to an object of class ROMEDB::Datatype

=back

=cut
 
__PACKAGE__->belongs_to(process => 'ROMEDB::Process', 
			{
			    'foreign.name' => 'self.process_name',
			    'foreign.component_name' => 'self.process_component_name',
			    'foreign.component_version' => 'self.process_component_version'
			    
			});


__PACKAGE__->belongs_to(accepts => 'ROMEDB::Datatype','datatype_name');

# replace accepts with datatype?
#__PACKAGE__->belongs_to(datatype => 'ROMEDB::Datatype','datatype_name');

1;

