package ROMEDB::ReturnValue;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::ReturnValue
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'return_value' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut


__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('return_value');

=head1 METHODS

=head1 Simple Accessors

=over 2

=item name
 
    Unique name. Primary Key

=item description

    A user-defined description of this return value. Optional.

=back

=cut


__PACKAGE__->add_columns(qw/name description/);
__PACKAGE__->set_primary_key(qw/name/);



=head1 Relationship Accessors

=over 2

=item process_return_values

  has_many relationship. 
  Returns a resultset in scalar context and an array of ROMEDB::ProcessReturnValue
  objects in list context.

  This is a join table. You probably don't want to use it directly.

=item process_return_values_rs

  Like process_return_values but always returns a resultset, even in list context.  

=item processes

  many_to_many relationship.
  Returns a resultset in scalar context and an array of ROMEDB::Process
  objects in list context

=item add_to_processes

  add_to method created by processes relationship.
  adds processes which generates this type of return value

=item set_processes

  set method created by processes relationship
  sets existing processes to use this return_value.

=back

=cut


__PACKAGE__->has_many(process_return_values=>'ROMDB::ProcessReturnValue','return_value');
__PACAKGE__->many_to_many(processes=>'procss_return_values', 'process');

 
1;
