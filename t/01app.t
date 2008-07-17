use strict;
use warnings;
use Test::More tests => 4;

BEGIN { use_ok 'Catalyst::Test', 'ROME' }

use ok "Test::WWW::Mechanize::Catalyst" => "ROME";
        
# Create two 'user agents' to simulate two different users ('test01' & 'test02')
my $ua = Test::WWW::Mechanize::Catalyst->new;
    
$ua->get_ok("http://localhost:3000/", "Check redirect of base URL") for $ua;
$ua->title_is("Login", "Check for login title") for $ua;
