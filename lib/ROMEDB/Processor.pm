package ROMEDB::Processor;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::Processor
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'processor' table of the ROME database

    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('processor');

=head1 METHODS

=head1 SIMPLE ACCESSORS

=over 2

=item name

   Unique name for this processor

=item description

   Optional (but recommended) description for this processor

=item perl_class

   The perl module which provides this processor. 

=back

=cut

__PACKAGE__->add_columns(qw/name description perl_class/);
__PACKAGE__->set_primary_key(qw/name/);


=head1 RELATIONSHIP ACCESSORS

=over 2 

=item processes

   has_many relationship
   Returns a resultset in scalar context and an array of ROMEDB::Process
   objects in list context

=item processes_rs

  Like processes but always returns a resultset even in list context

=back

=cut

__PACKAGE__->has_many(processes=>'ROMEDB::Process','processor');



=over 2

=item processes_pending

  has_many relationship
  Returns a resultset in scalar context and an array of ROMEDB::ProcessPending 
  objectes in list context.

=item processes_pending_rs

  Like processes_pending but always returns a resultset even in list context

=back

=cut

__PACKAGE__->has_many(processes_pending=>'ROMEDB::ProcessPending', 'processor');


 
1;
