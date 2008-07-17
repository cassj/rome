package ROMEDB::PersonPending;

use base qw/DBIx::Class/;

=head1 NAME

    ROMEDB::PersonPending

=head1 DESCRIPTION
    
    DBIC object representing a row in the 'person_pending' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    PersonPending is an optional extension of the Person table. 
    We define a belongs_to relationship here which sets proxy methods for the person_pending
    table's columns in the Person class, so in most cases, you probably want to access
    this class indirectly via ROMEDB::Person.

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('person_pending');

=head1 METHODS

=head1 Simple Accessors

=over 2

=item email_id

    ID code sent out in the admin and user confirmation emails.
    Used to prevent people being registered without their permission.

=item admin_approved

    Boolean. Has the administrator approved this registration yet?

=item user_approved

    Boolean, Has the user approved this registration yet?

=back

=cut

__PACKAGE__->add_columns(qw/username email_id admin_approved user_approved/);
__PACKAGE__->set_primary_key(qw/username/);


=head1 RELATIONSHIP ACCESSORS

=over 2

=item id

   As well as being a unique integer primary key, id is also a foreign key
   to the person table and has a belongs_to relationship defined on it such
   that it will expand to an object of class ROMEDB::Person.
   
   This belongs_to method also proxies methods for email_id, admin_approved 
   and user_approved to the ROMEDB::Person object for which id is a foreign key.
   This means for most purposes you should not need to access this class directly,
   but rather via a ROMEDB::Person object.

=back

=cut

__PACKAGE__->belongs_to(username => 'ROMEDB::Person','username');


1;
