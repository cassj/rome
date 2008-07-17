package ROMEDB::DatatypeExportMethod;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::DatatypeExportMethod 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datatype_export_method' 
    linking table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
    This is a linking table. The Datatype and ExportMethod classes define 
    many_to_many relationships, linking through this table. You may prefer to
    use the many_to_many relationship, rather that using the linking table 
    directly.

=head1 METHODS

=cut

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('datatype_export_method');
__PACKAGE__->add_columns(qw/datatype export_method/);
__PACKAGE__->set_primary_key(qw/datatype export_method/);

#Relationships
__PACKAGE__->belongs_to(datatype => 'ROMEDB::Datatype', 'datatype');
__PACKAGE__->belongs_to(export_method => 'ROMEDB::ExportMethod','export_method');    

=head1 RELATIONSHIP ACCESSORS

=head1 belongs_to accessors

=over 2

=item datatype 

    The datatype we are linking to an export_method
    Expands to an object of class ROMEDB::Datatype

=item export_method

    The export_method we are linking to a datatype
    Expands to an object of class ROMEDB::ExportMethod

=back

=cut

 
1;
