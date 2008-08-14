=head1 NAME

  ROME::Parser

=head1 SYNOPSIS

  use ROME::Parser;
  my $parser = ROME::Parser->new($type, $context);

=head1 DESCRIPTION

  Factory class for ROME parsers.

  Note that if you're writing ROME parsers, don't inherit
  from this, inherit from ROME::Parser::Base

=cut

package ROME::Parser;

use strict;
use warnings;

use Class::Factory::Util;

sub new {
  my $self = bless {}, shift;
  my $subclass = shift;

  unless ($subclass){
    warn 'Specify Parser required, eg: new ROME::Parser($type)';
    return undef;
  }
  #check the subclass is one we know about
  my %subclasses = map {$_=>1} __PACKAGE__->subclasses;
  unless ($subclasses{$subclass}){
    warn "Unknown Parser subclass requested";
    return undef;
  }

  #create and return an instance of it.
  $subclass = "ROME::Parser::$subclass";
  eval "require $subclass" or die "require failed for $subclass";
  my $newInstance =  $subclass->new(@_);
  return $newInstance;
}




1;

