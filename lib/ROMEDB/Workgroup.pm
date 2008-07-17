package ROMEDB::Workgroup;

use base qw/DBIx::Class/;


=head1 NAME
    
    ROMEDB::Workgroup
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'workgroup' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

=cut

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('workgroup');


=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item name

    Unique Workgroup Name. Primary Key.

=item description

    A user-defined description of this workgroup. Optional.

=back

=cut

__PACKAGE__->add_columns(qw/name description leader/);
__PACKAGE__->set_primary_key(qw/name/);


=head1 RELATIONSHIP ACCESSORS

=over 2

=item leader 

    The person who is in charge of this workgroup
    Expands to an object of class ROMEDB::Person

=back

=cut

__PACKAGE__->belongs_to(leader => 'ROMEDB::Person', 'leader');

=over 2

=item person_workgroups

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::PersonWorkgroups objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item person_workgroups_rs

    As person_workgroups, but forces the return of a resultset even in list context

=item people

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Person
    objects in list context

=item add_to_people

    add_to method created by the many_to_many relationship 'people'
    adds new people to the database

=item set_people

    set method created by the many_to_many relationship 'people'
    links existing people to this workgroup

=cut

__PACKAGE__->has_many(map_person_workgroup=>'ROMEDB::PersonWorkgroup','workgroup');
__PACKAGE__->many_to_many(people=>'map_person_workgroup','person');


=over2

=item join_requests

    A has_many relationship.

    Returns a resultset in scalar context and an array of ROMEDB::WorkgroupJoinRequest objects
    in list context.

=item invites

   A has_many relationship.

   Returns a resultset in scalar context and an array of ROMEDB::WorkgroupInvite objects 
   in list context.

=cut

__PACKAGE__->has_many(join_requests=>'ROMEDB::WorkgroupJoinRequest','workgroup');
__PACKAGE__->has_many(invites=>'ROMEDB::WorkgroupInvite','workgroup');



=over 2

=item map_datafile_workgroup

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::PersonDatafile objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item map_datafile_workgroup_rs

    As map_person_workgroup, but forces the return of a resultset even in list context

=item datafiles

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Datafile
    objects in list context

=item add_to_datafiles

    add_to method created by the many_to_many relationship 'datafiles'
    adds new related datafiles to the database

=item set_datafiles

    set method created by the many_to_many relationship 'datafiles'
    links existing datafiles to this workgroup

=cut


__PACKAGE__->has_many(map_datafile_workgroup=>'ROMEDB::DatafileWorkgroup','workgroup');
__PACKAGE__->many_to_many(datafiles=>'map_datafile_workgroup','datafile');


=over 2

=item map_experiment_workgroup

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::ExperimentWorkgroup objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item map_experiment_workgroup_rs

    As map_experiment_workgroup, but forces the return of a resultset even in list context

=item experiments

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Experiment
    objects in list context

=item add_to_experiments

    add_to method created by the many_to_many relationship 'experiments'
    adds new related experiments to the database

=item set_experiments

    set method created by the many_to_many relationship 'experiments'
    links existing experiments to this workgroup

=cut


__PACKAGE__->has_many(map_experiment_workgroup=>'ROMEDB::ExperimentWorkgroup','workgroup');
__PACKAGE__->many_to_many(experiments=>'map_experiment_workgroup','experiment');






=item cont_var_workgroups

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::ContVarWorkgroup objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item cont_vars

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::ContVar
    objects in list context

=cut

__PACKAGE__->has_many(cont_var_workgroups =>'ROMEDB::ContVarWorkgroup', 
		      {
			  'foreign.workgroup_name' => 'self.name'
		      });

__PACKAGE__->many_to_many(cont_vars=>'cont_var_workgroups', 'cont_var');






=item factor_workgroups

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::FactorWorkgroup objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item factors

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Factor
    objects in list context

=cut

__PACKAGE__->has_many(factor_workgroups =>'ROMEDB::FactorWorkgroup', 
		      {
			  'foreign.workgroup_name' => 'self.name'
		      });

__PACKAGE__->many_to_many(factors =>'factor_workgroups', 'factor');




 
1;
