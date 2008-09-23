use Test::More tests => 1;

use lib "../lib";

BEGIN {
use_ok( 'Catalyst::View::Bioseq' );
}

diag( "Testing Catalyst::View::Bioseq $Catalyst::View::Bioseq::VERSION, Perl 5.008006");
