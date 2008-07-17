package ROMEDB::Person;

use base qw/DBIx::Class/;
use YAML;

=head1 NAME
    
    ROMEDB::Person
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'person' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=head1 ACCESSORS

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('person');


=head1 SIMPLE ACCESSORS

=over 2

=item username

    Unique username for this person.
    Primary Key,

=item forename

    User's forename. Optional

=item surname

    User's surname. Optional

=item institution

    User's place of work. Optional.

=item address

    Contact Address. Optional

=item password

    Encrypted password.

=item email

    User's email address. Required.

=item created

    Timestamp for the creation of this user account. 

=back

=cut

__PACKAGE__->add_columns(qw/username forename surname institution address password email experiment_name experiment_owner created active data_dir upload_dir static_dir/);
__PACKAGE__->set_primary_key(qw/username/);


=head1 TABLE EXTENSIONS


    The ROMEDB::PersonPending table is a subclass of person, linked by username.
    The column accessors for PersonPending are proxied to this class, so if a person
    is pending then the following methods will return a value:

=over 2

=item email_id

    The code sent out in the emails to user and admin to confirm registration. 
    This is checked to prevent people being registered without their approval. 
    
=item admin_approved

    Boolean. Has the administrator of the site approved the registration yet?

=item user_approved

    Boolean. Has the user confirmed they wish to register yet?

=back


=cut

__PACKAGE__->might_have(pending => 'ROMEDB::PersonPending',
			undef, {proxy=>[qw/
					email_id
					admin_approved
					user_approved
					/]
			       });



=head1 RELATIONSHIP ACCESSORS

=over 2

=item experiment 

    The experiment the user currently has selected
    Expands to an object of class ROMEDB::Experiment

=back

=cut

__PACKAGE__->might_have(experiment_owner => 'ROMEDB::Person', {'foreign.username' => 'self.experiment_owner'});

__PACKAGE__->might_have(experiment => 'ROMEDB::Experiment', {
							     'foreign.name'  => 'self.experiment_name',
							     'foreign.owner' => 'self.experiment_owner'}, 
			{cascade_delete=>0});


#DEPRECATED. Remove as soon as any dep code is change.
__PACKAGE__->might_have(datafile => 'ROMEDB::Datafile',{
							'foreign.name'             => 'self.datafile_name',
							'foreign.experiment_name'  => 'self.experiment_name',
							'foreign.experiment_owner' => 'self.username',
						       },
			{cascade_delete=>0});    



=item datafiles

  has_many relationship
  Datafiles currently selected by this user
  An array of ROMEDB::Datafile objects

=cut


__PACKAGE__->has_many(selected_datafiles => 'ROMEDB::PersonDatafile',
		      {
			  'foreign.person'  => 'self.username',
		      });


__PACKAGE__->many_to_many(datafiles => 'selected_datafiles', 'datafile');



=over 2

=item workgroups_led

  A has_many relationship. A person can be leader of many workgroups
  We won't delete the workgroups if the user goes, though it would require admin
  priviledges to reassign the group.

=back

=cut

 __PACKAGE__->has_many(workgroups_led => 'ROMEDB::Workgroup', 'leader', {cascade_delete=>0});


=over 2

=item map_person_role
    
    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::PersonRole
    objects in list context.
    
    This is a join table. You probably don't want to use it directly.

=item map_person_role_rs

    As map_person_role but forces return of resultset even in list context.

=item roles

    A many_to_many relationship

    Returns a resultset in scalar context and an array of ROMEDB::Role
    objects in list context.

=item add_to_roles

    add_to method created by the many_to_many relationship 'roles'.
    creates a new role in the database

=item set_roles

    set method created by the many_to_many relationship 'roles'
    links an existing role to this person

=cut

__PACKAGE__->has_many(map_person_role=>'ROMEDB::PersonRole', 'person');
__PACKAGE__->many_to_many(roles=>'map_person_role', 'role');



=item person_workgroups

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::PersonWorkgroup objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item person_workgroups_rs

    As person_workgroup, but forces the return of a resultset even in list context

=item workgroups

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Workgroup
    objects in list context

=item add_to_workgroups

    add_to method created by the many_to_many relationship 'workgroups'
    adds a new workgroup to the database

=item set_workgroups

    set method created by the many_to_many relationship 'workgroups'
    links an existing workgroup to this person.

=cut

__PACKAGE__->has_many(map_person_workgroups=>'ROMEDB::PersonWorkgroup', 'person');
__PACKAGE__->many_to_many(workgroups=>'map_person_workgroups', 'workgroup');



=item workgroup_join_requests

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::WorkgroupJoinRequest objects
    in list context.

=cut


__PACKAGE__->has_many(workgroup_join_requests=>'ROMEDB::WorkgroupJoinRequest', 'person');




=item workgroup_invites

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::WorkgroupInvite objects
    in list context.

=cut


__PACKAGE__->has_many(workgroup_invites=>'ROMEDB::WorkgroupInvite', 'person');






=item pending_processes

    has_many relationship 

    returns a resultset or an array of ROMEDB::ProcessPending objects representing
    all the processes this person has currently queued.

=cut

#__PACKAGE__->has_many(pending_processes=>'ROMEDB::ProcessPending','person');



=item experiments

    has_many relationship

    returns a resultset or an array of ROMEDB::Experiment objects representing
    all the experiments belonging to this person.

=cut

__PACKAGE__->has_many(experiments=>'ROMEDB::Experiment', 'owner');


=back


=head2 new

  Overrides new to make user directories.

=cut
sub new{
  my ( $class, $attrs ) = @_;

  my $username = $attrs->{username};  
  my $config = YAML::LoadFile('rome.yml');

  #create the user directories
  my $userdata = $config->{userdata} or die "no userdata directory defined in config.";

  #do some checks
  die  'The userdata directory specified in rome.yml does not exist.'
    unless (-e $config->{userdata});
  die "ROME can't write to the userdata directory specified in rome.yml."
    unless (-w $config->{userdata});
  die "userdata directory for user $username already exists."
    if (-e $config->{userdata}.'/'.$username);
  
  #and make the directory
  mkdir $config->{userdata}.'/'.$username
    or die "Failed to make userdata directory: $username";
  mkdir $config->{userdata}.'/'.$username.'/uploads'
    or die "Failed to make upload directory for user ".$username;
  
  #and store their location in the database
  $attrs->{data_dir} = $config->{userdata}.'/'.$username;
  $attrs->{upload_dir} = $config->{userdata}.'/'.$username.'/uploads';

  #create the static user dir
  die "ROME can't write to the static directory"
    unless (-w $config->{root}.'/static');
  die "static data directory for user $username already exists."
    if (-e $config->{root}.'/static/'.$username);
  
  #and make the directory
  mkdir $config->{root}.'/static/'.$username
    or die "Failed to make static directory for $username";
  mkdir $config->{root}.'/static/'.$username.'/logs'
      or die "Failed to make log directory for $username";

  #store the location in the database
  $attrs->{static_dir} = $config->{root}.'/static/'.$username;
  
  #okay, let dbic create the person.
  $class->next::method($attrs);
  
}

=head2 delete

  Overrides the parental delete to remove user directories.

=cut
sub delete {
  my $self = shift;

  #grab the directory names before deletion
  my $upload_dir = $self->upload_dir;
  my $data_dir   = $self->data_dir;
  my $static_dir = $self->static_dir;

  #let DBIC do the database bit
  $self->next::method( @_ );

  #and remove the associated directories.
  if (-e $upload_dir){
    rmdir $upload_dir
      or warn "Couldn't delete upload directory: $upload_dir. Please delete manually.";
  }
  if(-e $data_dir){
    rmdir $data_dir
      or warn "Couldn't delete data directory $data_dir. Please delete manually";
  }
  if (-e $static_dir){
    rmdir $static_dir
      or warn "Couldn't delete static directory $static_dir. Please delete manually";
  }
    
}

 

1;
