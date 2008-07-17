package ROMEDB::DatatypeMetadata;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::DatatypeMetadata
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datatype_metadata' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('datatype_metadata');

__PACKAGE__->add_columns(qw/name datatype_name description optional/);

__PACKAGE__->set_primary_key(qw/name datatype_name /);


__PACKAGE__->belongs_to(datatype => 'ROMEDB::Datatype','datatype_name');


=head1 METHODS

=over 2

=item description

    A user-defined description of this datafile. Optional.

=item optional

   A boolean value indicating whether this piece of metadata is optional
   for datafiles of this datatype

=back

=item datatype

    The datatype of this datafile
    Expands to an object of clases ROMEDB::Datatype

=cut

