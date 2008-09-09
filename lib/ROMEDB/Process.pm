package ROMEDB::Process;

use base qw/DBIx::Class/;

=head1 NAME
    
    ROMEDB::Process
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'process' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly. 

=cut

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('process');


=head1 METHODS

=over 2

=item name

    Unique name for this process. Primary Key

=item display_name

   Name for this process which can be shown to users. 

=item template_file

    The template file to be parsed into the script for this process.

=item description

    Optional textual description of this process.

=cut

__PACKAGE__->add_columns(qw/name component_name component_version tmpl_file description display_name processor/);
__PACKAGE__->set_primary_key(qw/name component_name component_version/);



=item component

  belongs_to relationship to the component table.

=cut

__PACKAGE__->belongs_to('component' => 'ROMEDB::Component',
		       {
			'foreign.name' => 'self.component_name',
			'foreign.version' => 'self.component_version'
		       });


=item process_accepts

  has_many relationship.
  Returns a resultset in scalar context and an array of ROMEDB::ProcessAccepts 
  objects in list context

  This is a join table. You probaby don't want to use it directly.

=item accepts

  many_to_many relationship
  Returns a resultset in scalar context and an array of ROMEDB::Datatype
  objects in list context

=cut

__PACKAGE__->has_many(process_accepts=>'ROMEDB::ProcessAccepts',
		      {'foreign.process_name' => 'self.name',
		       'foreign.process_component_name' => 'self.component_name',
		       'foreign.process_component_version' => 'self.component_version'}
		     );

__PACKAGE__->many_to_many(accepts=>'process_accepts','accepts');



=item process_creates

  has_many relationship.
  Returns a resultset in scalar context and an array of ROMEDB::ProcessCreates
  objects in list context

  This is a join table. You probaby don't want to use it directly.

=item process_creates_rs

  Like process_creates but always returns a resultset, even in list context.

=item creates

  many_to_many relationship
  Returns a resultset in scalar context and an array of ROMEDB::Datatype
  objects in list context

=item add_to_creates

  add_to method created by the creates relationship.
  adds a new datatype to the database

=item set_creates

  set_ method created by the creates relationship
  tells this process is creates an existing datatype


=cut

__PACKAGE__->has_many(process_creates=>'ROMEDB::ProcessCreates',
		      {'foreign.process_name' => 'self.name',
		       'foreign.process_component_name' => 'self.component_name',
		       'foreign.process_component_version' => 'self.component_version'}
		     );
__PACKAGE__->many_to_many(creates=>'process_creates','creates');




=item parameters

    has_many relationship to the process_parameter table
    Returns a list of ROMEDB::Parameter objects

=cut

__PACKAGE__->has_many(parameters=>'ROMEDB::Parameter',
		      {
		       'foreign.process_name'=>'self.name',
		       'foreign.process_component_name' => 'self.component_name',
		       'foreign.process_component_version' => 'self.component_version',
		      });



=item fieldsets

    has_many relationship to the fieldset table
    Returns a list of ROMEDB::Fieldset objects

=cut


__PACKAGE__->has_many(fieldsets=>'ROMEDB::Fieldset',
		      {
		       'foreign.process_name'=>'self.name',
		       'foreign.process_component_name' => 'self.component_name',
		       'foreign.process_component_version' => 'self.component_version',
		      },
		      { order_by => 'position'},
    );


=item jobs

   has_many relationship to the jobs tables.
   Returns a list or resultset of ROMEDB::Job objects

=cut

__PACKAGE__->has_many(jobs => 'ROMEDB::Job',
		      {
		       'foreign.process_name' => 'self.name',
		       'foreign.process_component_name' => 'self.component_name',
		       'foreign.process_component_version' => 'self.component_version'
		      });

















 
1;
