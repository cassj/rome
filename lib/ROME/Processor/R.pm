package ROME::Processor::R;

use strict;
use warnings;

use base 'ROME::Processor::Base';

##overriden methods from ROME::Processor
sub _suffix { return 'R'; }
sub cmd_name{ return 'R'}
sub cmd_params {return '--slave --vanilla'};

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
