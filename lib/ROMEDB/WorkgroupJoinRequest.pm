package ROMEDB::WorkgroupJoinRequest;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::WorkgroupJoinRequest
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'workgrou_join_request' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    Entries in this table are stored until workgroup owner approval, upon which
    they are moved into the person_workgroup mapping table. 

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('workgroup_join_request');
__PACKAGE__->add_columns(qw/person workgroup/);
__PACKAGE__->set_primary_key(qw/person workgroup/);


=head1 RELATIONSHIP ACCESSORS

=head1 belongs_to accessors

=over 2

=item person

    The person who is being assigned to a workgroup
    Expands to an object of class ROMEDB::Person

=item workgroup

    The workgroup to which a person is being assigned
    Expands to an object of class ROMEDB::Workgroup

=back

=cut


__PACKAGE__->belongs_to(person => 'ROMEDB::Person', 'person');
__PACKAGE__->belongs_to(workgroup => 'ROMEDB::Workgroup','workgroup');    

 
1;
