use inc::Module::Install;

name 'ROME';
all_from 'lib/ROME.pm';

requires 'Catalyst' => '5.7003';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Plugin::Cache::FastMmap';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Store::DBIC';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::RequireSSL';
requires 'Catalyst::Plugin::FormValidator';
requires 'Catalyst::Plugin::FillInForm';
requires 'Catalyst::Plugin::Prototype';
requires 'Catalyst::Plugin::UploadProgress';
requires 'Catalyst::Plugin::SubRequest';
requires 'Module::Find';

requires 'YAML'; 
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
