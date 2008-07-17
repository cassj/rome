use strict;
use warnings;

use Test::More 'no_plan';
  
use Digest::SHA1  qw(sha1);
use YAML;
use Data::Dumper;

use ROMEDB;

use ok "Test::WWW::Mechanize::Catalyst" => "ROME";
        
# Create two 'user agents' to simulate two different users ('test01' & 'test02')
my $ua1 = Test::WWW::Mechanize::Catalyst->new;
my $ua2 = Test::WWW::Mechanize::Catalyst->new;


# load up your config and get make sure admin and user confirm options are off 
# and disable secure server stuff (otherwise your cookies don't work for http:/ pages)
my ($config) = YAML::LoadFile('rome.yml');

# Make a DB connection for messing with your test objects by hand
my $schema = ROMEDB->connect($config->{db}->{dsn} ,
			     $config->{db}->{user},
			     $config->{db}->{password});

die "Connection to database failed" unless $schema;

    SKIP: {
        skip("Can't test user management with user_confirm or admin_confirm enabled in rome.yml") 
	  if ($config->{registration}->{user_confirm} || $config->{registration}->{admin_confirm});
        skip("Can't test user management with require_sql enabled in rome.yml")
	  if ($config->{require_ssl}->{enable});
	      #get register page
	      $_->get_ok("http://localhost:3000/user/register","Get the registration page") for $ua1,$ua2;
	      $_->title_is("Register","Check for registration title") for $ua1,$ua2;

	      #check registration error messages
	      $ua1->submit_form(
				fields => {
					  },
				button => 'submit',
			       );
	      $ua1->content_contains('<div class="name">username:</div> <div>Missing</div>', "Check missing username message");
	      $ua1->content_contains('<div class="name">password:</div> <div>Missing</div>', "Check missing password message");
	      $ua1->content_contains('<div class="name">password2:</div> <div>Missing</div>', "Check missing password2 message");
	      $ua1->content_contains('<div class="name">email:</div> <div>Missing</div>', "Check missing email message");
	      
	      $ua1->submit_form(
		  fields => {
			     email       => 'notavalidemailaddress',
			     address     => '../*%',
                             institution => '&*^jds@',
			     forename    => '^&*(',
                             surname     => ']{9=njk',
                             username    => 'I have spaces',
			    },
		  button => 'submit',
			       );
	      
	      $ua1->content_contains('<div class="name">email:</div> <div>Your email address is invalid or inaccessible.</div>',
		       'Check invalid email message');

	      $ua1->content_contains('<div class="name">address:</div> <div>Disallowed characters. Please use only letters, numbers, spaces, hyphens and underscores.</div>',
		       'Check invalid address');

	      $ua1->content_contains('<div class="name">institution:</div> <div>Disallowed characters. Please use only letters, numbers, spaces, hyphens and underscores.</div>',
		       'Check invalid institution');

	      $ua1->content_contains('<div class="name">forename:</div> <div>Disallowed characters. Please use only letters, numbers, spaces, hyphens and underscores.</div>',
		       'Check invalid forename');

	      $ua1->content_contains('<div class="name">surname:</div> <div>Disallowed characters. Please use only letters, numbers, spaces, hyphens and underscores.</div>',
		       'Check invalid surname');

	      $ua1->content_contains('<div class="name">username:</div> <div>Invalid username. Please use only letters, numbers, hyphens and underscores. No spaces.</div>',
		       'Check no spaces in username');

	      
	#register test01
	$ua1->submit_form(
			  fields => {
				     username     => 'test01',
				     password     => 'test01',
				     password2    => 'test01',
				     email        => 'test@localhost.com',
				     forename     => 'test',
				     surname      => 'one',
				     institution  => 'some place',
				     address      => 'some street, some town',
				    },
			  button => 'submit',
			 );

	
	#register test02
	$ua2->submit_form(
			  fields => {
				     username     => 'test02',
				     password     => 'test02',
				     password2    => 'test02',
				     email        => 'test@localhost.com',
				     forename     => 'test',
				     surname      => 'two',
				     institution  => 'some place',
				     address      => 'some street, some town',
				    },
			  button => 'submit',
			 );
	
	#did it work?
	$_->title_is("Registration Complete", 'Check for registration complete page') for $ua1,$ua2;

	#check redirect of index URL
	$_->get_ok("http://localhost:3000/user", "Check redirect of user URL") for $ua1, $ua2;
	$_->title_is("Login", "Check for login title") for $ua1, $ua2;
	
	#check user/login
	$_->get_ok("http://localhost:3000/user/login", "Check user/login") for $ua1, $ua2;
	$_->title_is("Login", "Check for login title") for $ua1, $ua2;
	$_->content_contains("Please login to use ROME",
			     "Check we are NOT logged in") for $ua1, $ua2;
	
	#do login
	$ua1->submit_form(
			  fields => {
				     username => 'test01',
				     password => 'test01',
				    },
			  button    => 'submit',	    
			 );
	
	$ua2->submit_form(
			  fields => {
				     username => 'test02',
				     password => 'test02',
				    },
			  button => 'submit',
			 );
	#did login work?
	$_->title_is("Login Successful","Check successful login") for $ua1, $ua2;	

	# Go back to the login page and it should show that we are already logged in
	$_->get_ok("http://localhost:3000/user/login", "Return to '/login'") for $ua1,$ua2;
	$_->title_is("Login", "Check for login page") for $ua1,$ua2;
	$_->content_contains("Please Note: You are already logged in as",
		     "Check we ARE logged in" ) for $ua1,$ua2;
	
	#check your user account details.
	$_->get_ok("http://localhost:3000/user/account", "Check redirect to account page") for $ua1,$ua2;
	$_->title_is("My Account", "Check account page title") for $ua1, $ua2;
	$_->content_contains('<input type="text" name="email" value="test@localhost.com"/>','check email field') for $ua1,$ua2;
	$_->content_contains('<input type="text" name="forename" value="test"/>', 'check forename field') for $ua1, $ua2;
	$_->content_contains('<input type="text" name="institution" value="some place"/>', 'check institution field') for $ua1,$ua2;
	$_->content_contains('<textarea name="address">some street, some town</textarea>', 'check address field') for $ua1,$ua2;
	$_->content_contains('<input type="text" name="surname" value="one"/>', 'check surname field') for $ua1;
	$_->content_contains('<input type="text" name="surname" value="two"/>', 'check surname field') for $ua2;
	      
	#update account details.
	$ua1->submit_form(
			  fields => {
				     email         => 'new_email@localhost.com',
				     forename      => '',
				     institution   => '',
				     surname       => '',
				     address       => '',
				    },
			  button    => 'submit',	    
			 );
	
	
	# check we can't get the delete page
	$_->get_ok("http://localhost:3000/user/delete", "get the delete page") for $ua1,$ua2;
        $_->content_contains("Access Denied",
		     "Check we are DENIED access" ) for $ua1, $ua2;


        # create a user via the database 
	# doesn't get user directories etc, so doesn't need to be deleted via the model
	my $admin = $schema->resultset('Person')->create({username=>'admin01',
							  password=>sha1($config->{authentication}->{dbic}->{password_pre_salt}
							            .'admin01'
                                                                    .$config->{authentication}->{dbic}->{password_post_salt}),
							  email=>'foo@bar.com',
							 });

	# give admin role to your new user (this role is created on DB install). 
        $schema->resultset('PersonRole')->create({person=>'admin01', role=>'admin'});
        
	#now create a new user agent for this user and login
	my $ua_admin = Test::WWW::Mechanize::Catalyst->new;
	$_->get_ok("http://localhost:3000/user/login", 'login admin user') for $ua_admin;
	$ua_admin->submit_form(
			  fields => {
				     username => 'admin01',
				     password => 'admin01',
				    },
			  button    => 'submit',	    
			 );

	# and try the delete page again.
	$_->get_ok("http://localhost:3000/user/delete", "get the delete page") for $ua_admin;
	$_->title_is("Delete a user","Check we are PERMITTED access") for $ua_admin;

        #delete the 2 users via the model
	$_->get_ok("http://localhost:3000/user/delete/test01", "delete test user 1") for $ua_admin;
	$ua_admin->content_contains('User test01 was deleted','Check deletion of user 1');
	$_->get_ok("http://localhost:3000/user/delete/test02", "delete test user 2") for $ua_admin;
	$ua_admin->content_contains('User test02 was deleted','Check deletion of user 2');

	#and delete the admin user by hand (role will cascade delete)
	$admin->delete; 
	
     }
