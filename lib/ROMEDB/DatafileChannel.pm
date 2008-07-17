package ROMEDB::DatafileChannel;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('datafile_channel');
__PACKAGE__->add_columns(qw/datafile channel/);
__PACKAGE__->set_primary_key(qw/datafile channel/);

#Relationships
__PACKAGE__->belongs_to(datafile => 'ROMEDB::Datafile', 'datafile');
__PACKAGE__->belongs_to(channel => 'ROMEDB::Channel','channel');    

=head1 NAME
    
    ROMEDB::DatafileChannel 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'datafile_channel' linking table 
    of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a linking table. Both Datafile and Channel implement many_to_many
    shortcuts which link through this table. You may prefer to use those, rather
    than accessing the link table directly.
 
=head1 ACCESSORS

=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item datafile

    The datafile we are linking to a channel
    Expands to an object of class ROMEDB::Datafile

=item channel

    The channel we are linking to a datafile
    Expands to an object of class ROMEDB::Datafile

=back

=cut

 
1;
