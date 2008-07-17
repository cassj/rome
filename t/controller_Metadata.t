use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'ROME' }
BEGIN { use_ok 'ROME::Controller::Metadata' }

ok( request('/metadata')->is_success, 'Request should succeed' );


