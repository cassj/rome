package ROMEDB::ExportMethod;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('export_method');
__PACKAGE__->add_columns(qw/name description extension/);
__PACKAGE__->set_primary_key(qw/name/);


#Relationships

=head1 NAME
    
    ROMEDB::ExportMethod 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'export_method' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item name

    Export Method Name.
    Unique. Primary Key.

=item description

    Optional description for this export method

=item extension

    File extension for exports of this type

=back
    
=cut

 
1;
