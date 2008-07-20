package Template::Plugin::Class::Path;

use strict;
use warnings;
use base 'Template::Plugin';
use Class::Path;

our $VERSION = 2.70;
our $DEBUG   = 0 unless defined $DEBUG;
our @DUMPER_ARGS = qw( Indent Pad Varname Purity Useqq Terse Freezer
                       Toaster Deepcopy Quotekeys Bless Maxdepth );
our $AUTOLOAD;


sub new {
    my ($class, $context, $params) = @_;
    my ($key, $val);
    $params ||= { };


    foreach my $arg (@DUMPER_ARGS) {
	no strict 'refs';
	if (defined ($val = $params->{ lc $arg })
	    or defined ($val = $params->{ $arg })) {
	    ${"Data\::Dumper\::$arg"} = $val;
	}
    }

    bless { 
	_CONTEXT => $context, 
    }, $class;
}

sub dump {
    my $self = shift;
    my $content = Dumper @_;
    return $content;
} 


sub dump_html {
    my $self = shift;
    my $content = Dumper @_;
    for ($content) {
	s/&/&amp;/g;
	s/</&lt;/g;
	s/>/&gt;/g;
	s/\n/<br>\n/g;
    }
    return $content;
}

1;
