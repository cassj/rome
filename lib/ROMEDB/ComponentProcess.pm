package ROMEDB::ComponentProcess;

use base qw/DBIx::Class/;

#Table Description    
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('component_process');
__PACKAGE__->add_columns(qw/component process/);
__PACKAGE__->set_primary_key(qw/component process/);

#Relationships
__PACKAGE__->belongs_to(component => 'ROMEDB::Component', 'component');
__PACKAGE__->belongs_to(process => 'ROMEDB::Process','process');    



=head1 NAME
    
    ROMEDB::ComponentProcess
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'component_process' linking table 
    of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
    This is a linking table.
    The Component and Process classes define many_to_many relationships 
    through this link. You may prefer to use these rather than access
    the link table directly.

=head1 ACCESSORS
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item component 


    The component we're linking to a process
    Expands to an object of class ROMEDB::Component

=item process

    The process we're linking to a component
    Expands to an object of class ROMEDB::Process

=back

=cut

 
1;
