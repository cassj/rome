package ROMEDB::Chiptype;

use base qw/DBIx::Class/;

#Table Description    
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('chiptype');
__PACKAGE__->add_columns(qw/name description/);
__PACKAGE__->set_primary_key(qw/name/);

#Relationships
__PACKAGE__->has_many(chips => 'ROMEDB::Chips', 'chiptype');


=head1 NAME
    
    ROMEDB::Chiptype
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'chiptype' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item name
 
    Unique name. Primary Key.

=item description

    A user-defined description of this chiptype. Optional.

=back
    
=head1 RELATIONSHIPS

=head1 has_many accessors

=over 2

=item chips

    Chips belonging to this chip type. 
    Individual items are of class ROMEDB::Chip

=item chips_rs

    Same as chips, but always returns a resultset, even in list context

=back

=cut

 
1;
