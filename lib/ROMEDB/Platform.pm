package ROMEDB::Platform;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('platform');
__PACKAGE__->add_columns(qw/name channels description/);
__PACKAGE__->set_primary_key(qw/id/);

#Relationships

=head1 NAME
    
    ROMEDB::Platform
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'platform' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item name
 
    Unique name. Primary Key

=item description

    An optional textual description for this platform

=item channels

    The number of channels this platform has.

=back

=cut

 
1;
