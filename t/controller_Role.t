use strict;
use warnings;
use Test::More qw/no_plan/;

BEGIN { use_ok 'Catalyst::Test', 'ROME' }
BEGIN { use_ok 'ROME::Controller::Role' }
  
use ok "Test::WWW::Mechanize::Catalyst" => "ROME";
        
# Create a user agent ua
my $ua = Test::WWW::Mechanize::Catalyst->new;

#login the user agent
$ua->get_ok("http://localhost:3000/user/login", "Get login page");
$ua->submit_form(
		  fields => {
			     username => 'test01',
			     password => 'test01',
			    },
		  button    => 'submit',	    
		 );


