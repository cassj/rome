#!/usr/bin/perl 


# This script creates an admin role, and an admin user with that role
# username is admin and password is admin.
# On install, login as admin and change this password!

use FindBin;
use lib "$FindBin::Bin/../lib";

use ROMEDB;
use YAML;
use Digest::SHA1  qw(sha1);

#connect to the DB
my $config = YAML::LoadFile('rome.yml');
my $con = $config->{Model::ROMEDB}->{connect_info};
my $schema = ROMEDB->connect( $con->[0],$con->[1],$con->[2] );

#encrypt the pw
my $pw =  sha1($config->{authentication}->{dbic}->{password_pre_salt}
		  .'admin'
		  .$config->{authentication}->{dbic}->{password_post_salt});


#make the user
my $admin_user = $schema->resultset('Person')->create({
    username => 'admin',
    password => $pw,
    email    => $config->{admin_email},
});

#make the admin role
my $role = $schema->resultset('Role')->find('admin');
unless ($role){
$role = $schema->resultset('Role')->create({
    name => 'admin',
    description => 'administrator',
});
}

#give the user admin rights
my $person_role = $schema->resultset('PersonRole')->create({
    person => $admin_user->username,
    role => $role->name,
});

print "Done\n";
