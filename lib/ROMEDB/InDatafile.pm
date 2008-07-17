package ROMEDB::InDatafile;

use base qw/DBIx::Class/;

=head1 NAME
  
  ROMEDB::InDatafile

=head1 DESCRIPTION 

    For Catalyst, this is designed to be used through ROME::Model::ROMEDB.
    Offline utilities may wish to use this class directly.

    This is a class representing the in_datafile table in the ROMEDB. This is 
    a many-to-many mapping table between Datafile and Job.
    You probably want to use the many-to-many accessors defined in Datafile and Job
    rather than using this class directly.


=cut


__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('in_datafile');


=head1 METHODS

=over 2

=item jid
 
    Job ID. Expands to an object of class ROMEDB::Job

=item datafile
    
    The datafile id which is an input to this job.
    Expands to an object of class ROMEDB::Datafile

=item 

=back
    
=cut


__PACKAGE__->add_columns(qw/jid datafile_name datafile_experiment_name datafile_experiment_owner/);
__PACKAGE__->set_primary_key(qw/jid datafile_name datafile_experiment_name datafile_experiment_owner/);


__PACKAGE__->belongs_to(job=>'ROMEDB::Job', 'jid');
__PACKAGE__->belongs_to(datafile=>'ROMEDB::Datafile', {'foreign.name'=> 'self.datafile_name',
						     'foreign.experiment_name' => 'self.datafile_experiment_name',
						     'foreign.experiment_owner' => 'self.datafile_experiment_owner',
		      });




 
1;
