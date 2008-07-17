package ROMEDB::ContVar;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('cont_var');
__PACKAGE__->add_columns(qw/name owner description status/);
__PACKAGE__->set_primary_key(qw/name owner/);

#Relationships

=head1 NAME
    
    ROMEDB::ContVar 
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'cont_var' table of the ROME database
    (Continuous (independent) Variable)
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item name

    Variable Name.
    Unique for a given user. 

=item description

    A user-defined description of this variable. Optional.

=back

=head1 Relationship Accessors

=over 2

=item owner

  belongs_to method.
  
  The person who created this variable

  Inflates to an object of class ROMEDB::Person

=back

=cut

__PACKAGE__->belongs_to(owner=>'ROMEDB::Person','owner');


=item values

  has_many relationship to the cont_var_value table.

  The measured values of this continuous variable

  Inflates to a list of ROMEDB::ContVarValue objects

=cut

__PACKAGE__->has_many(values=>'ROMEDB::ContVarValue', {
						       'foreign.cont_var_name'  => 'self.name',
						       'foreign.cont_var_owner' => 'self.owner',
						      });





=item cont_var_experiments

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::ContVarExperiment objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item experiments

    A many_to_many relationship

    Returns a resultset in scalar context and an array of ROMEDB::Experiments
    objects in list context

=cut

__PACKAGE__->has_many(cont_var_experiments =>'ROMEDB::ContVarExperiment', 
		      {
			  'foreign.cont_var_name' => 'self.name', 
			  'foreign.cont_var_owner'=> 'self.owner'
		      });

__PACKAGE__->many_to_many(experiments=>'cont_var_experiments', 'experiment');






=item cont_var_workgroups

    A has_many relationship. 

    Returns a resultset in scalar context and an array of ROMEDB::ContVarWorkgroup objects
    in list context.
    
    This is a join table. You probably don't want to use it directly.

=item workgroup

    A many_to_many relationship 
 
    Returns a resultset in scalar context and an array of ROMEDB::Workgroup
    objects in list context

=cut

__PACKAGE__->has_many(cont_var_workgroups =>'ROMEDB::ContVarWorkgroup', 
		      {
			  'foreign.cont_var_name' => 'self.name', 
			  'foreign.cont_var_owner'=> 'self.owner'
		      });

__PACKAGE__->many_to_many(workgroups=>'cont_var_workgroups', 'workgroup');






=item ROMEDB::ContVarByUser

  This is not a method. It's a result source.
  It returns only the continuous variables which are visible for
  the given user. 

  like:

  my $factors = $c->model('ContVarByUser')->search ({}, {bind=>[$username, $username]})

=cut

my $source = __PACKAGE__->result_source_instance();
my $new_source = $source->new( $source );
$new_source->source_name( 'ContVarByUser' );
  
$new_source->name( \<<SQL );
( 
 SELECT DISTINCT c.* FROM cont_var AS c
 LEFT JOIN (cont_var_workgroup AS cw, person_workgroup AS pw)
       ON (c.name=cw.cont_var_name
	   AND c.owner=cw.cont_var_owner
           AND cw.workgroup_name = pw.workgroup)
 WHERE c.status='public' 
 OR c.owner=? 
 OR (c.status='shared' 
     AND pw.person=?)
)

SQL


#hacky fix to sort out DBIC's lookup tables.
@ROMEDB::ContVarByUser::ISA = ('ROMEDB::ContVar');
$new_source->result_class('ROMEDB::ContVarByUser');


ROMEDB->register_source( 'ContVarByUser' => $new_source );





1;
