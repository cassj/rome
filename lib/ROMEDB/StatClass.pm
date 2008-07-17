package ROMEDB::StatClass;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('stat_class');
__PACKAGE__->add_columns(qw/id name description multi_level multi_fac/);
__PACKAGE__->set_primary_key(qw/id/);

=head1 NAME
    
    ROMEDB::StatClass
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'stat_class' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item id
 
    Unique numerical ID. Primary Key.

=item name

    Name of stat class.
    This can be anything meaningful to the user and doesn't have to be unique.

=item description

    A user-defined description of this stat class. Optional.

=item multi_fac

    Boolean. Is this stat capable of dealing with multiple factors

=item multi_level

    Boolean. Is this stat capable of dealing with more than 2 levels

=back

=cut
 
1;
