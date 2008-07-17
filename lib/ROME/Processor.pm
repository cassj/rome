=head1 NAME

  ROME::Processor

=head1 SYNOPSIS

  use ROME::Processor;
  my $R_processor = new ROME::Processor('R');

=head1 DESCRIPTION

  Factory class for ROME processors. 

  Note that if you're writing ROME processors, don't inherit
  from this, inherit from ROME::Processor::Base

=cut

package ROME::Processor;

use strict;
use warnings;

use Class::Factory::Util;

sub new {
  my $self = bless {}, shift;
  my $subclass = shift;

  unless ($subclass){
    warn 'Specify Processor required, eg: new ROME::Processor($process->processor)';
    return undef;
  }
  #check the subclass is one we know about
  my %subclasses = map {$_=>1} __PACKAGE__->subclasses;
  unless ($subclasses{$subclass}){
    warn "Unknown Processor subclass requested";
    return undef;
  }

  #create and return an instance of it.
  $subclass = "ROME::Processor::$subclass";
  eval "require $subclass" or die "require failed for $subclass";
  my $newInstance =  $subclass->new(@_);
  return $newInstance;
}




1;

