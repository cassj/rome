package ROME::ProcessorFactory;


use strict;
use warnings;

our $VERSION = '0.01';

sub new {
  my $self = bless {}, shift;
  $self->context(shift);
  my @processors = $self->context->model('ROMEDB::Processor')->all;
  $self->processors({map {$_->name => $_} @processors});
  return $self;
}

sub new {
  my $self = bless {}, shift;
  my $subclass = shift;

  my $newInstance = new Bar(...);
  return $newInstance;
}






1;
