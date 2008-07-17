package ROMEDB::Role;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::Role

=head1 DESCRIPTION
    
    DBIC object representing a row in the 'role' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('role');


=head1 METHODS

=head1 SIMPLE ACCESSORS

=over 2

=item name

  Name for this role

=item description

  Description for this role

=back

=cut

__PACKAGE__->add_columns(qw/name description/);
__PACKAGE__->set_primary_key(qw/name/);

=head1 RELATIONSHIP ACCESSORS

=over 2

=item map_person_role

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::PersonRole objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item map_person_role_rs

    As map_person_role, but forces the return of a resultset even in list context

=item people

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Person
    objects in list context

=item add_to_people

    add_to method created by the many_to_many relationship 'people'
    adds new people to the database

=item set_people

    set method created by the many_to_many relationship 'people'
    links existing people to this role

=cut

__PACKAGE__->has_many(map_person_role=>'ROMEDB::PersonRole', 'role');
__PACKAGE__->many_to_many(people=>'map_person_role', 'person');

 
1;
