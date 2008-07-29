package ROME::Controller::Base;

=head1 NAME

ROME::Controller::Base

=head1 DESCRIPTION

A base class for ROME controllers providing common functions

=head1 METHODS

=over 2

=cut

use strict;
use warnings;
use base 'Catalyst::Controller';
use Module::Find;

use ROME::ActiveProcesses;

sub auto :Private{
  my ($self, $c) = @_;
  $self->active_processes($c);
}

sub active_processes{
  my ($self, $c) = @_;

  #check if the ap in the session has diff expt_name, owner and datafiles
  #to the current ones, if not, just return that
  my $ap = $c->session->{active_processes};
  unless ($ap 
	  && $ap->experiment_name == $c->user->experiment->name
	  && $ap->experiment_owner == $c->user->experiment->owner
	  && grep {exists $ap->datafiles->{$_->name}} $c->user->datafiles){
    
    $c->session->{active_processes} = ROME::ActiveProcesses->new($c);
    
  }

  return $c->session->{active_processes};
}
















#=head2 set_active_components
#
#  A utility method to update the active components hash. 
#
#  The active components hash defines which components are 
#  available for use given the current user, experiment and datafile
#  This method can be called by a component if it changes any of these.
#
#=cut
#
#sub set_active_components{
#   my ($self, $c) = @_;
#
#   warn "called set_active_components";
#   #get components that are always active
#   my @always_active = WebR::M::CDBI::Component->search(
#       always_active => 1
#    );

#   #work out which components should be active for this datafile
#   my $comp_hash={};

#   foreach my $component (@always_active){
#     $comp_hash->{$component->name}='active';
#     warn $component->name;
#   }

#   #if we have a user and that user has a selected datafile...
#   if ($c->user && $c->user->user->datafile && $c->user->user->datafile->id){
#     my $datafile = $c->user->user->datafile;
#     warn "This user does not currently have a datafile selected" unless $datafile;

#     #get components that need certain datatypes
#     my @components = WebR::M::CDBI::Component->search(
#                                                       always_active => 0
#                                                      );
#     use Data::Dumper;
#     foreach my $component (@components){
#       foreach my $process ($component->processes){
#         my %recognised_datatypes =  map {$_->name=>1} ($process->accepts);
#         $comp_hash->{$component->name} = 'active' if ($recognised_datatypes{$datafile->datatype} || ($recognised_datatypes{Any} ));
#         warn Dumper($comp_hash);
#       }
#     }
#   }

#   #store the comp_hash in the session
#   $c->session->{active_components} = $comp_hash;
# }


#=head2 processor_factory
#
#  A utility method which returns an instance of the requested processor.
#
#  Currently, R is the only one available.
#
#  Takes the processor name as an argument. 
#  eg. for ROME::Processor::R, the name is 'R'
#
#
#=cut
#
#
##why the hell is this here?
#
#sub processor_factory {
#  my ($self,$c,$proc_req) = @_;
#
#  die "No processor type specified" unless $proc_req;
#  
#  #avoid evaling a string provided by the user 
#  #The lookup hash is setup in ROME.pm
#  if (my $proc_class =  $c->config->{processors}->{$proc_req}){
#    eval "require $proc_class";
#    return $proc_class->new($c);
#  }
#  else {
#    $c->log->error("Invalid processors $proc_req requested");
#    return 0;
#  }
#}
#
#
## can be called from components to check that the datafiles are valid for 
## the process
## returns true if it's ok, returns false if not and sticks the required datafile
## types in the stash error_msg.
#sub is_active: Private{
#    my ($self, $c) = @_;
#    warn ref($self);
#    
#    
#}
#

#  ###
#  # Check user has write permissions on this experiment
#
#  my $expt_name = $self->context->user->experiment_name;
#  my $expt_owner = $self->context->user->experiment_owner;
#
#  unless ($expt_owner->username eq $self->context->user->username || $self->context->check_user_roles("admin")){
#    $self->context->stash->{error_msg} = "You can't create files in someone else's experiment";
#    return 0;
#  }
#  
#  ####
#  # Check that the currently selected datafiles match up with process_accepts
#
#  my %in_datafile_types;
#  $in_datafile_types{$_->datatype->name}++ 
#    for $self->context->user->datafiles;
#
#  my %acceptable_datafile_types;
#  $acceptable_datafile_types{$_->accepts->name}++
#	for $self->process->process_accepts;
#
#  unless (Compare(\%in_datafile_types, \%acceptable_datafile_types) ){
#    my $error = join ' ', 
#      map {$_->accepts->name.' ('.$_->num.')'} 
#	$self->process->process_accepts;
#
#      $self->context->stash->{error_msg} =  
#	scalar(keys %acceptable_datafile_types) ?
#	  "Wrong datafiles selected. Requires datafiles of types: $error":
#	    "Wrong datafiles selected. No input datafiles required";
#
#   
#    return 0;
#  }


=back

=cut


1;
