package ROMEDB::Queue;

use base qw/DBIx::Class/;

=head1 NAME
  
  ROMEDB::Queue

=head1 DESCRIPTION 

      For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is the job queue.

=cut


__PACKAGE__->load_components(qw/PK::Auto InflateColumn::DateTime Core/);
__PACKAGE__->table('queue');


=head1 METHODS

=head1 Relationship Methods

=head1 Simple Accessors

=over 2

=item jid

   Job ID: Unique 

=item pid
 
   nix Process ID

=item status

    Status of the process (QUEUED, PROCESSING, HALTED)

=item start_time

    Time at which the process began processing
    Stored as a unix timestamp, but will inflate to 
    a perl DateTime object on retrieval
    
=cut


__PACKAGE__->add_columns(qw/jid pid status/);
__PACKAGE__->add_columns( start_time => { data_type => 'datetime' } );


__PACKAGE__->set_primary_key(qw/jid/);

__PACKAGE__->belongs_to(jid => 'ROMEDB::Job', 'jid');


=back
=cut
 
1;
