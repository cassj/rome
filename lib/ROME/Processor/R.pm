package ROME::Processor::R;

use strict;
use warnings;

use base 'ROME::Processor::Base';

##overriden methods from ROME::Processor
sub _suffix { return 'R'; }
sub cmd_name{ return 'R'}
sub cmd_params {return '--slave --vanilla'};

#takes template file and arguments,
#runs R call and returns named bits of output in a hash
#could all of this go in the processor base class?
sub process_script
  {
    my $self = shift;
   
    die "Nothing in $self->script. Parse template first" unless $self->script;
 
    my $script = $self->script;

    #STDERR/STDOUT to a filehandle
    my $pid = open(OUT, $self->cmd." < '$script' |") 
      or die "Couldn't fork: $!\n";

    my ($line, $out);
    while($line = <OUT>)
      {
	print STDERR $line;
	#$out->{$1}= [split /,/,$2] if $line=~/^([\w|\-]+)\?(.+$)/;
       }
	
    if (close(OUT)){
      $self->send_email_confirmation;
    }
    else
      {
	die "Problem with process ".__PACKAGE__." : $!";
	$self->send_admin_alert;
      }
    
      $self->out($out);
  }



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

ROME::Processor::R - ROME R processor

=head1 SYNOPSIS

  use Rome::Processor;
  my $R = new ROME::Processor($process->processor);

=head1 DESCRIPTION

R processor for ROME


=head1 SEE ALSO

ROME

=head1 AUTHOR

Cass Johnston, E<lt>johnston@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Cass Johnston

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
