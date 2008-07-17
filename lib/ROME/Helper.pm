package ROME::Helper;

use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use Template;

=head1 NAME

  ROME::Helper

=head1 DESCRIPTION 

  Methods for creating new ROME components

=head1 SYNOPSIS

  use ROME::Helper::Create;
  my $creator = ROME::Helper::Create->new();
  $creator->create('My::Component::Name', $dir);

=head1 METHODS 

=cut

__PACKAGE__->mk_accessors(qw(component_name));


=head2 new
 
  Creates a new instance of this class.
  
  my $creator = ROME::Helper::Create->new();

=cut

sub new {
  my $class = shift;
  return bless {}, $class;
}



=head2 create

  Generates a new skeleton component.
  
  $creator->create("My::Component", $author, $dir);

  $author is your name. Defaults to 'Anon'

  $dir is the path to your components directory.
  By default, it assumes you are in your ROME directory, and defaults to 'components'.
  
=cut

sub create {
  my ($self, $name, $author, $dir) = @_;

  $dir = 'components' unless $dir;
  die "You don't have write permissions for the specified directory" unless -w $dir;
  die "No component name provided" unless $name;
  
  my $pkg_name = $name;
  my $path = $name;
  $path =~ s/::/\//g;

  $name =~ s/::/-/g;
  $name = lc($name);
  
  die "A directory $name already exists. Please remove it if you wish to create a new $name component" if -e "$dir/$name";
  
  #create the dirs you need
  mkdir ("$dir/$name");
  mkdir ("$dir/$name/lib");
  mkdir ("$dir/$name/lib/ROME");
  mkdir ("$dir/$name/lib/ROME/Controller");
  mkdir ("$dir/$name/root");
  mkdir ("$dir/$name/root/src");
  mkdir ("$dir/$name/root/R_templates");
 
  my $lib_path = "lib/ROME/Controller"; 
  
  my @lib_dirs = split '/', $path;
  
  foreach (@lib_dirs[0..$#lib_dirs-1]){
    mkdir ("$dir/$name/$lib_path/$_");
    $lib_path.="/$_";
  }
  
  my $output = "$dir/$name/$lib_path/$lib_dirs[-1].pm";
  $self->_make_controller($output, $dir, $name, $pkg_name, $author);

  $output = "$dir/$name/root/src/$name/index.tt2";
  $self->_make_view($output, $dir, $name);

  $output = "$dir/$name/root/R_templates/$name.tt2";
  $self->_make_R($output, $dir, $name);

}


sub _make_controller{
  my ($self, $output, $dir, $name, $pkg_name, $author) = @_;

  my $config = {
      INCLUDE_PATH => "$dir/templates",  
      INTERPOLATE  => 1,               
      POST_CHOMP   => 1,  
  };

  my $template = Template->new($config);

  # define template variables for replacement
  my $vars = {
      name  => $name,
      pkg_name => $pkg_name,
      author => $author || "Anon",
  };

  # specify input filename, or file handle, text reference, etc.
  my $input = 'controller.tt2';

  # process input template, substituting variables
  $template->process($input, $vars, $output)
      || die $template->error();
}


sub _make_view{
  my ($self, $output, $dir, $name) =@_;

  my $path = $name;
  $path =~ s/-/\//g;

  #change the start and end tags cos it's a template of a template
  my $config = {
      INCLUDE_PATH => "$dir/templates",  
      INTERPOLATE  => 1,               
      POST_CHOMP   => 1,    
      START_TAG    => '~',
      END_TAG      => '~',
          
  };

  my $template = Template->new($config);

  my $vars = {
      name  => $name,
      path  => $path,
  };

  my $input = 'view.tt2';

  $template->process($input, $vars, $output)
      || die $template->error();

}

sub _make_R{
  my ($self, $output, $dir, $name) =@_;

  my $path = $name;
  $path =~ s/-/\//g;

  #change the start and end tags cos it's a template of a template
  my $config = {
      INCLUDE_PATH => "$dir/templates",  
      INTERPOLATE  => 1,               
      POST_CHOMP   => 1,    
      START_TAG    => '~',
      END_TAG      => '~',
          
  };

  my $template = Template->new($config);

  my $vars = {
      name  => $name,
      path  => $path,
  };

  my $input = 'R.tt2';

  $template->process($input, $vars, $output)
      || die $template->error();

}

sub install {
  my $self = shift;


}

1;
