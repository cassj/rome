package ROMEDB::Level;

use base qw/DBIx::Class/;

#Table Definition
__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('level');
__PACKAGE__->add_columns(qw/factor_name factor_owner name description/);
__PACKAGE__->set_primary_key(qw/factor_name factor_owner name/);





=head1 NAME
    
    ROMEDB::Level
    
=head1 DESCRIPTION
    
    DBIC object representing a row in the 'level' table of the ROME database
    
    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.
 
=head1 ACCESSORS

=head1 Simple Accessors

=over 2

=item id
 
    Unique numerical ID. Primary Key.

=item name

    Level Name.
    This can be anything meaningful to the user and doesn't have to be unique.

=item description

    A user-defined description of this level. Optional.

=back
    
=head1 RELATIONSHIPS

=head1 belongs_to accessors

=over 2

=item factor

    The factor of which this is a level
    Expands to an object of class ROMEDB::Factor

=cut

__PACKAGE__->belongs_to(factor => 'ROMEDB::Factor', {'foreign.name'=>'self.factor_name',
						     'foreign.owner' => 'self.factor_owner',
						    });



=item outcome_levels

    A has_many relationship to the outcome_level mapping table
    You probably don't want to use this directly.

=item outcomes

   A many_to_many relationship with the outcomes in outcome_level.
   The experimental outcomes at this level
 
=cut

__PACKAGE__->has_many(outcome_levels=>'ROMEDB::OutcomeLevel',
		      {
          'foreign.level_name'          => 'self.name',
	  'foreign.level_factor_name'   => 'self.factor_name',
	  'foreign.level_factor_owner'  => 'self.factor_owner',
		      });

__PACKAGE__->many_to_many(outcomes=>'outcome_levels','outcome');







=back

=cut

 
1;
