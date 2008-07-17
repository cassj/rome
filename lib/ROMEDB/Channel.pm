package ROMEDB::Channel;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('channel');
__PACKAGE__->add_columns(qw/id name chip rawdatafile description dye colour treatment/);
__PACKAGE__->set_primary_key(qw/id/);

#Relationships
__PACKAGE__->belongs_to(chip => 'ROMEDB::Chip', 'chip');
__PACKAGE__->belongs_to(treatment => 'ROMEDB::Treatment','treatment');    
__PACKAGE__->has_many(channel_datafile => 'ROMEDB::DatafileChannel', 'datafile');
__PACKAGE__->many_to_many(datafiles => 'channel_datafile', 'datafile');


=head1 NAME
    
    ROMEDB::Channel 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'channel' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item id
 
    Unique numerical ID. Primary Key.

=item name

    Channel Name.
    This can be anything meaningful to the user and doesn't have to be unique.

=item rawdatafile

    The raw datafile from which this channel data came. 

=item description

    A user-defined description of this channel. Optional.

=back
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item chip 

    The chip from which this channel is derived.
    Expands to an object of class ROMEDB::Chip

=item treatment 

    The treatment of the tissue on this channel. 
    Expands to an object of class ROMEDB::Treatment

=back

=head1 has_many accessors

=over 2

=item channel_datafile

    channel_datafile is a link table.
    There is a many_to_many shortcut datafiles method.

=item channel_datafile_rs

    Same as channel_datafile, but always returns a resultset, even in list context

=item add_to_channel_datafile

    Allows you to add channel_datafile objects related to your Channel

=back

=head1 many_to_many accessors

=over 2 

=item datafiles

    Datafiles information from this channel has been used to create. 
    Returns a resultset of ROMEDB::Datafile object

=item add_to_datafiles

    Add a datafile to this channel.
    
=back

=cut

 
1;
