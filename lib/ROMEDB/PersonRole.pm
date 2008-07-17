package ROMEDB::PersonRole;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('person_role');
__PACKAGE__->add_columns(qw/person role/);
__PACKAGE__->set_primary_key(qw/person role/);

#Relationships
__PACKAGE__->belongs_to(person => 'ROMEDB::Person', 'person');
__PACKAGE__->belongs_to(role => 'ROMEDB::Role','role');    


=head1 NAME
    
    ROMEDB::PersonRole
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'person_role' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
    This is a linking table which is used by the many_to_many relationship between
    the person and role tables. In most cases, you probably want to use this table 
    indirectly via the ROMEDB::Person and ROMEDB::Role classes, rather than accessing
    it directly.

=head1 ACCESSORS
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item person 

    The person who is being assigned a role
    Expands to an object of class ROMEDB::Person

=item role

    The role that is being assigned to a person
    Expands to an object of class ROMEDB::Role

=back

=cut

 
1;
