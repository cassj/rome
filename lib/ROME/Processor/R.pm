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

WebR::R - Perl extension for blah blah blah

=head1 SYNOPSIS

  use WebR::R;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for WebR::R, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Cass Johnston, E<lt>johnston@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Cass Johnston

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
