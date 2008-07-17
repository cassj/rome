package ROME;

use strict;
use warnings;

use Catalyst::Runtime '5.70';
use Module::Find;

=head1 NAME

ROME - Catalyst based application

=head1 SYNOPSIS

    Start ROME with script/rome_server.pl

    ROME can also be run under apache 
    See  L<ROME::Manual> for details.

=head1 DESCRIPTION

    R-Omics Made Easy. 
    A Catalyst Web Framework for building GUIs for Bioconductor.

=head1 CATALYST PLUGINS

=over 2

=item -Debug

  Activates the debug mode.

=item ConfigLoader

  Provides automatic loading of the configuration from the YAML file
  rome.yml in the application's home directory.

=item StaticSimple

  Serves static files from ROME's root directory.

=item Authentication

  Add login and logout methods to catalyst context.
  Various configuration settings in rome.yml under authentication.

=item Authentication::Store::DBIC

  Backend for Authentication plugin to store user details in database via DBIx::Class

=item Authentication::Credential::Password

  Backend for Authentication plugin to deal with password checking.

=item Session

  Provides session management. Adds the session hashref to the catalyst context, which
  can be used to store information across requests.

=item Session::Store::FastMmap

  Backend for Session plugin. 
  Deals with the server-side storage of session data using Cache::FastMmap

=item Session::State::Cookie

  Backend for Session plugin. 
  Deals with the client-side storage of session keys using cookies. 
 
=item RequireSSL

  Adds the require_ssl method to the catalyst context. 
  Call this method in an action to force a redirect to a secure server.
  Note that this is automatically disabled under the rome_server.pl test server.
  Configuration in rome.yml under require_ssl.

=item FormValidator

  Allows you to use Data::FormValidator to check form parameters, via
  the form object in your catalyst context.

=item FillInForm

  Fills forms automatically, based on data from a previous HTML form

=item UploadProgress

  Helper for generating upload fields with pretty ajax progress bars.
  Requires 2 concurrent connections, so if you want to use the upload progress
  plugin in testing, start ROME with script/rome_poe.pl instead of 
  script/rome_server.pl.

=item Cache::FastMmap

  Uses an mmap'ed file to act as a shared memory interprocess cache 
  This is used by the UploadProgress plugin to share information between
  the upload and the ajax upload_progress processes.

=item 

=back

=cut


use Catalyst qw/
                -Debug 
                ConfigLoader 
                Static::Simple
                StackTrace
                Cache::FastMmap

                Authentication
                Authentication::Store::DBIC
                Authentication::Credential::Password
                Authorization::Roles
 
                Session
                Session::Store::FastMmap
                Session::State::Cookie
           
                RequireSSL

                FormValidator
                FillInForm 

                Prototype
 
                UploadProgress

                SubRequest

                /;


 #               Server 
 #               Server::XMLRPC



our $VERSION = '0.01';


=head1 CONFIG 

  The config settings defined here provide a default.
  They may be overridden in ROME.yml to suit your requirements.

=cut

__PACKAGE__->config( name => 'ROME' );

__PACKAGE__->setup;

#if we've got a relative path to user data, make it a full one, relative to root
unless (__PACKAGE__->config->{userdata}=~/\/.+/){
  __PACKAGE__->config->{userdata}= __PACKAGE__->config->{root}.'/'.__PACKAGE__->config->{userdata};
}

# static::simple include paths
__PACKAGE__->config->{static}->{include_path} = [
						 __PACKAGE__->config->{root}.'/static',
						 __PACKAGE__->config->{root}.'/static/images',
					];
__PACKAGE__->config->{static}->{logging} = 1;


=head1 SEE ALSO

L<ROME::Controller::Root>, L<Catalyst>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
