package ROMEDB::ProcessReturnValue;

use base qw/DBIx::Class/;

=head1 NAME

  ROMEDB::ProcessReturnValue

=head1 DESCRIPTION

  DBIC object representing a row in the 'process_return_value' linking
  table in the ROME database

  For Catalyst, this is designed to be used through ROME::Model::ROMEDB
  Offline utilities may which to use this class directly.

  This is a join table, you probably don't want to access it directly.

=cut


__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('process_return_value');


__PACKAGE__->add_columns(qw/process return_value/);
__PACKAGE__->set_primary_key(qw/process return_value/);

=head1 METHODS

=head1 Relationship Accessors

=over 2

=item process


    The process we are linking to a return_value
    Expands to an object of class ROMEDB::Process

=item return_value

    The return_value we're linking to a process
    Expands to an object of class ROMEDB::ReturnValue

=back


=cut


__PACKAGE__->belongs_to(return_value => 'ROMEDB::Parameter', 'return_value');
__PACKAGE__->belongs_to(process => 'ROMEDB::Process','process');    

1;
