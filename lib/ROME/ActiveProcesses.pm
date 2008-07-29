package ROME::ActiveProcesses;

use strict;
use warnings;

=head1 NAME

  ROME::ActiveProcesses

=head1 DESCRIPTION

  Class to hold information about the currently active processes
  in ROME

=head1 SYNOPSIS

 my $ap = ROME::ActiveProcesses->new($catalyst_context);

 Will return undef if there are no active processes.

=head1 METHODS

=over 2

=cut


sub new {
  my ($class, $c) = @_;
  die "missing catalyst context" unless $c;
  my $self = bless {}, $class;
  $self->_set_active_processes($c);
  return $self;
}

#internal method which retrieves the relevant stuff out of the
#cat context.
sub _set_active_processes{
  my ($self,$c) = @_;

  #keep a note of the relevant context details.
  return unless $c->user;
  $self->{username} = $c->user->username;
  return unless my $expt = $c->user->experiment;
  $self->{experiment_name} = $expt->name or return;
  $self->{experiment_owner} = $expt->owner->username or return;
  
  #build the selected datafiles lookup hash
  my @datafiles = $c->user->datafiles or return;
  foreach (@datafiles){
    $self->{datafiles}->{$_->name} = 1;
  }

  #ok, now get the datatypes of the datafiles and the number 
  #of each type required
  my $datatypes = {};
  $datatypes->{$_->datatype->name}++ foreach @datafiles;
  
  #now retrive the process which accept that combination of datatypes.
  #there's no point in testing all of them, just grab the processes that are
  #ok for the first datatype and check those.
  my $d = $datafiles[0]->datatype->name;
  my $processes = $c->model('Process')->search
    ({
      'process_accepts.datatype_name' => $d,
     },
     {
      join => 'process_accepts',
      prefetch => ['process_accepts'],
       }
     );

  while(my $proc = $processes->next){
    my $test = {};
    $test->{$_}++ foreach map {$_->datatype_name} $proc->process_accepts;
    #is test equal to datatypes?
    my $ok = 1;
    foreach (keys %$datatypes)
      {
	$ok = 0 unless exists $test->{$_} && $datatypes->{$_} == $test->{$_};
      }
    $self->{processes}->{$proc->component_name}->{$proc->component_version}->{$proc->name} = 1 if $ok;
  }
}


=item username

Accessor for the username

=cut
sub username{
  my $self = shift;
  return $self->{username};
}

=item experiment_name

Accessor for the experiment_name

=cut
sub experiment_name{
  my $self = shift;
  return $self->{experiment_name};
}

=item experiment_owner

Accessor for the experiment_owner

=cut
sub experiment_owner{
  my $self = shift;
  return $self->{experiment_owner};
}

=item

Accessor for the datafiles, returned as a lookup hash ref
of the form
$datafiles = {datafile1 => 1,
              datafile2 => 1,}

=cut
sub datafiles{
  my $self = shift;
  return $self->{datafiles};
}


=item processes

Accessor for the currently active processes. 
Returned as a lookup hash of the form
$processes = {component1 =>{version => {process1 => 1,
                                     process2 =>1,}},
              component2 =>{version => {process1=>1,}},
}

Only active processes are included in the hash

=cut
sub processes{
  my $self = shift;
  return $self->{processes};
}





=back

=cut

1;