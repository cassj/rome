package ROMEDB::Chip;

use base qw/DBIx::Class/;
    
#Table Description
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('chip');
__PACKAGE__->add_columns(qw/id chiptype experiment name description /);
__PACKAGE__->set_primary_key(qw/id/);

#Relationships
__PACKAGE__->belongs_to(chiptype => 'ROMEDB::Chiptype', 'chiptype');
__PACKAGE__->belongs_to(experiment=>'ROMEDB::Experiment', 'experiment');  
__PACKAGE__->has_many(channels => 'ROMEDB::Channel', 'chip');


=head1 NAME
    
    ROMEDB::Chip 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'chip' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item id
 
    Unique numerical ID. Primary Key.

=item name

    Chip Name.
    This can be anything meaningful to the user and doesn't have to be unique.

=item description

    A user-defined description of this chip. Optional.

=back
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item chiptype

    The chiptype (design, rather than platform, eg rat2302). 
    Expands to an object of class ROMEDB::Chiptype

=item experiment

    The experiment of which this chip is part.
    Expands to an object of class ROMEDB::Experiment

=back

=head1 has_many accessors

=over 2

=item channels

    The channels on this chip.
    Each channel is an object of class ROMEDB::Channel

=item channel_rs

    Same as channels, but always returns a resultset, even in list context

=item add_to_channels

    Allows you to add channels to this chip.

=back

=cut



1;
