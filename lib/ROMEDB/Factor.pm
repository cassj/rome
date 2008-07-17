package ROMEDB::Factor;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('factor');
__PACKAGE__->add_columns(qw/name owner description status/);
__PACKAGE__->set_primary_key(qw/name owner/);

#Relationships

=head1 NAME
    
    ROMEDB::Factor 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'factor' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item name

    Factor Name.
    Unique for a given user

=item description

    A user-defined description of this factor. Optional.

=back

=head1 Relationship Accessors

=over 2

=item owner

  belongs_to method.
  
  The person who owns this factor

  Inflates to an object of class ROMEDB::Person

=back

=cut

__PACKAGE__->belongs_to(owner=>'ROMEDB::Person','owner');






=item levels

   has_many relationship

   The levels of this factor

   Inflates to ROMEDB::Level objects

=cut


__PACKAGE__->has_many(levels => 'ROMEDB::Level', 
		      {
			  'foreign.factor_name' => 'self.name',
			  'foreign.factor_owner' => 'self.owner',
		      });


=item factor_experiments

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::FactorExperiment objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item experiments

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Experiments
    objects in list context

=cut

__PACKAGE__->has_many(factor_experiments =>'ROMEDB::FactorExperiment', 
		      {
			  'foreign.factor_name' => 'self.name', 
			  'foreign.factor_owner'=> 'self.owner'
		      });

__PACKAGE__->many_to_many(experiments=>'factor_experiments', 'experiment');




=item factor_workgroups

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::FactorWorkgroup objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item workgroup

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Workgroup
    objects in list context

=cut

__PACKAGE__->has_many(factor_workgroups =>'ROMEDB::FactorWorkgroup', 
		      {
			  'foreign.factor_name' => 'self.name', 
			  'foreign.factor_owner'=> 'self.owner'
		      });

__PACKAGE__->many_to_many(workgroups=>'factor_workgroups', 'workgroup');




=item ROMEDB::FactorByUser

  This is not a method. It's a result source.
  It returns only the factors which are visible for
  the given user. 

  like:

  my $factors = $c->model('FactorByUser')->search ({}, {bind=>[$username, $username]})

=cut

my $source = __PACKAGE__->result_source_instance();
my $new_source = $source->new( $source );
$new_source->source_name( 'FactorByUser' );
  
$new_source->name( \<<SQL );
( 
 SELECT DISTINCT f.* FROM factor AS f
 LEFT JOIN (factor_workgroup AS fw, person_workgroup AS pw)
       ON (f.name=fw.factor_name
	   AND f.owner=fw.factor_owner
           AND fw.workgroup_name = pw.workgroup)
 WHERE f.status='public' 
 OR f.owner=? 
 OR (f.status='shared' 
     AND pw.person=?)
)

SQL


#hacky fix to sort out DBIC's lookup tables.
@ROMEDB::FactorByUser::ISA = ('ROMEDB::Factor');
$new_source->result_class('ROMEDB::FactorByUser');


ROMEDB->register_source( 'FactorByUser' => $new_source );


 
1;
