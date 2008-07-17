package ROMEDB::DatatypeRelationship;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::DatatypeRelationship 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datatype_relationship' 
    linking table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table used to determine the inheritance hierarchy of the
    R datatypes in the database. Kinda like the ISA array in perl. The datatype class
    defines many_to_many relationships through this table for children and parents. 
    You may wish to use these many_to_many relationships instead of using the mapping
    class directly.

=head1 METHODS

=cut 

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('datatype_relationship');
__PACKAGE__->add_columns(qw/child parent/);
__PACKAGE__->set_primary_key(qw/child parent/);


__PACKAGE__->belongs_to(child => 'ROMEDB::Datatype', 'child');
__PACKAGE__->belongs_to(parent => 'ROMEDB::Datatype','parent');    


=head1 RELATIONSHIP ACCESSORS

=head1 belongs_to accessors

=over 2

=item child 

    The datatype which is a subclass of the other datatype in the relationship
    Expands to an object of class ROMEDB::Datatype

=item parent

    The datatype from which the other datatype in the relationship inherits
    Expands to an object of class ROMEDB::Datatype

=back

=cut

 
1;
