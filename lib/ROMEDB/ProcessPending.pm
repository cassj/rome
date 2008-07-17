package ROMEDB::ProcessPending;

use base qw/DBIx::Class/;

=head1 NAME
  
  ROMEDB::ProcessPending

=head1 DESCRIPTION 

      For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is the process queue.

=cut


__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('process_pending');


=head1 METHODS

=head1 Relationship Methods

=head1 Simple Accessors

=over 2

=item id
 
    Unique numerical ID. Primary Key.

=item script

    Location of the script for this process.
    (which has been parsed by the processor from the template in the process) 

=item status

    Status of the process (QUEUED, PROCESSING, HALTED, COMPLETE)

=item start_time

    Time at which the process began processing

=item pid

    PID of the process being run

=back
    
=cut


__PACKAGE__->add_columns(qw/id processor script status error start_time pid datafile person process experiment/);
__PACKAGE__->set_primary_key(qw/id/);


__PACKAGE__->belongs_to(processor => 'ROMEDB::Processor', 'processor');
__PACKAGE__->belongs_to(datafile => 'ROMEDB::Datafile', 'datafile');
__PACKAGE__->belongs_to(person => 'ROMEDB::Person', 'person');
__PACKAGE__->belongs_to(process => 'ROMEDB::Process', 'process');
__PACKAGE__->belongs_to(experiment => 'ROMEDB::Experiment', 'experiment');

 
1;
