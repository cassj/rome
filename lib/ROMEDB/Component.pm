package ROMEDB::Component;

use base qw/DBIx::Class/;
    

=head1 NAME

  ROMEDB::Component

=head1 DESCRIPTION

  DBIC object representing a row in the 'component' table of the ROME database
 
  For Catalyst, this is desiged to be used through ROME::Model::ROMEDB.
  Offline utilities may wish to use this class directly

=cut


__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('component');

=head1 METHODS

=over 2

=item name
 
    (PK) Unique name 

=item version
 
    (PK) Version number of this component in the form
    major.minor.patch

=item description

    An optional (but advisable) description of the component

=item installed

    A boolean flag stating whether this version of this component 
    is currently installed. 
    Only one version of a given component name can be installed 
    at a time, but other versions remain in the database, along
    with the database entries for their processes as these are
    referenced by any jobs in which they were used. This provides
    a record of the specific version of a process used to create
    any given datafile. 

=cut

__PACKAGE__->add_columns(qw/name version always_active description installed/);
__PACKAGE__->set_primary_key(qw/name version/);


=item processes

    Processes associated with this component

=cut


__PACKAGE__->has_many(processes => 'ROMEDB::Process', 
		       {
			   'foreign.component_name' => 'self.name',
			   'foreign.component_version' => 'self.version'
		       });




=back

=cut

1;
