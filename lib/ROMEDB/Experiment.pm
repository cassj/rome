package ROMEDB::Experiment;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('experiment');
__PACKAGE__->add_columns(qw/name owner date_created pubmed_id description status/);
__PACKAGE__->set_primary_key(qw/name owner/);

#Relationships
__PACKAGE__->belongs_to(owner => 'ROMEDB::Person', 'owner');

#DEPRECATED
#__PACKAGE__->belongs_to(root_datafile => 'ROMEDB::Datafile', {'foreign.name'             => 'self.root_datafile_name',
#							      'foreign.experiment_name'  => 'self.name',
#							      'foreign.experiment_owner' => 'self.owner'});
#

=head1 NAME
    
    ROMEDB::Experiment
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'experiment' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item id
 
    Unique numerical ID. Primary Key.

=item name

    Experiment Name.
    This can be anything meaningful to the user and doesn't have to be unique.

=item description
    
    User defined textual description of the experiment. Optional.

=item date_created

    Date this experiment was created.

=item pubmed_id

    Optional pubmed ID of the paper in which this experiment was published.

=back

=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item owner
    
    The owner of this experiment - generally the person who created it.
    Expands to an object of class ROMEDB::Person

=item root_datafile

    The root_datafile in this experiment. 
    This should be a single file, derived from the initial raw data.
    eg. An AffyBatch datafile.
    Expands to an object of class ROMEDB::Datafile

=back


=head2 has_many accessors.

=over 2

=item 

=cut

__PACKAGE__->has_many("current_users"=>'ROMEDB::Person',
		      {'foreign.experiment_name'=>'self.name',
		       'foreign.experiment_owner'=>'self.owner'
		      },
		      {cascade_delete=>0}
		     );

=item map_experiment_workgroups

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::ExperimentWorkgroup objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item workgroups

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Workgroup
    objects in list context

=cut

__PACKAGE__->has_many(map_experiment_workgroups =>'ROMEDB::ExperimentWorkgroup', {
						  	  'foreign.experiment_name' => 'self.name', 
							  'foreign.experiment_owner'=> 'self.owner'
										});

__PACKAGE__->many_to_many(workgroups=>'map_experiment_workgroups', 'workgroup');




=item datafiles

 has_many relationship to the datafile table in the database
 Datafiles which belong to this experiment
 Returns a list of ROMEDB::Datafile objects.

=cut

__PACKAGE__->has_many(datafiles=>'ROMEDB::Datafile', 
		      {
			  'foreign.experiment_name' => 'self.name',
			  'foreign.experiment_owner' => 'self.owner',
		      });

=item outcomes

  has_many relationship to the outcome table in the database

=cut

__PACKAGE__->has_many(outcomes=>'ROMEDB::Outcome',
		      { 'foreign.experiment_name' => 'self.name',
			'foreign.experiment_owner' => 'self.owner',
		      });


=item jobs

    has_many relationship to the job table in the database
    Jobs which belong to this experiment
    Returns a list of ROMEDB::Job objects

=cut

__PACKAGE__->has_many(jobs=> 'ROMEDB::Job',
		      {
			  'foreign.experiment_name' => 'self.name',
			  'foreign.experiment_owner' => 'self.owner'
		      });



=head2 root_jobs

    a has many on the RootJobs class, which is a DBIx::Class ResultSource
    defined in the Jobs table to only return jobs which are root.

=cut

__PACKAGE__->has_many(root_jobs=>'ROMEDB::RootJob',
		      {
			  'foreign.experiment_name' => 'self.name',
			  'foreign.experiment_owner' => 'self.owner',
		      });


=head2 root_datafiles

    a has_many on the RootDatafile class, which is a DBIx::Class ResultSource
    defined in the datafile table to only return jobs which are root

=cut

__PACKAGE__->has_many(root_datafiles=> 'ROMEDB::RootDatafile',
		      {
			  'foreign.experiment_name' => 'self.name',
			  'foreign.experiment_owner' => 'self.owner',
 		      });







=item factor_experiments

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::FactorExperiment objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item factors

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Factor
    objects in list context

=cut

__PACKAGE__->has_many(factor_experiments =>'ROMEDB::FactorExperiment', 
		      {
			  'foreign.experiment_name' => 'self.name', 
			  'foreign.experiment_owner'=> 'self.owner'
		      });

__PACKAGE__->many_to_many(factors=>'factor_experiments', 'factor');




=item cont_var_experiments

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::ContVarExperiment objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item cont_vars

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::ContVar
    objects in list context

=cut

__PACKAGE__->has_many(cont_var_experiments =>'ROMEDB::ContVarExperiment', 
		      {
			  'foreign.experiment_name' => 'self.name', 
			  'foreign.experiment_owner'=> 'self.owner'
		      });

__PACKAGE__->many_to_many(cont_vars => 'cont_var_experiments', 'cont_var');





=item selected_by

  A has many relationship to the person table.

=cut

__PACKAGE__->has_many(selected_by => 'ROMEDB::Person', 
		      {
		       'foreign.experiment_name' => 'self.name',
		       'foreign.expreiment_owner' => 'self.owner',
		      });





=head2 delete

  Overrides the parental delete to prevent shared experiments
  from being deleted and to ensure that if experiment is
  currently selected by the user it is deselected before
  deletion.

=cut
sub delete {
  my $self = shift;

  die "Can't delete shared experiments" unless $self->status eq "private";

  #let DBIC do the database bit
  $self->next::method( @_ );

}












=item ROMEDB::ExperimentByUser

  This is not a method. It's a result source.
  It returns only the experiments which are visible for
  the given user. 

  like:

  my $experiments = $c->model('ExperimentByUser')->search ({}, {bind=>[$username, $username]})

=cut

my $source = __PACKAGE__->result_source_instance();
my $new_source = $source->new( $source );
$new_source->source_name( 'ExperimentByUser' );
  
$new_source->name( \<<SQL );
( 

 SELECT DISTINCT e.* FROM experiment AS e
 LEFT JOIN (experiment_workgroup AS ew, person_workgroup AS pw)
       ON (e.name=ew.experiment_name
	   AND e.owner=ew.experiment_owner
           AND ew.workgroup = pw.workgroup)
 WHERE e.status='public' 
 OR e.owner=? 
 OR (e.status='shared' 
     AND pw.person=?)
)

SQL


#hacky fix to sort out DBIC's lookup tables.
@ROMEDB::ExperimentByUser::ISA = ('ROMEDB::Experiment');
$new_source->result_class('ROMEDB::ExperimentByUser');


ROMEDB->register_source( 'ExperimentByUser' => $new_source );


1;

