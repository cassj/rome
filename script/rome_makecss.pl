#!/usr/bin/perl

=head1 rome_makecss.pl

  Generates the static rome.css file from the templates in
  css/*

  Assumes files in root/ unless you specify the name of a skin
  like script/rome_makecss.pl skinname

=cut

use Template;

my $skin = shift @ARGV;
my $path = 'root';
$path .= "/skins/$skin" if $skin;
die "can't find directory $path" unless -d $path;

my $in_path = "$path/css";
my $out_path = "$path/static/css";

my $config = {
    INCLUDE_PATH => $in_path,
    INTERPOLATE  => 1,
    POST_CHOMP   => 1,
    OUTPUT_PATH  => $out_path,
    PRE_PROCESS  => 'col',

};

my $template = Template->new($config);

$template->process('rome.css', {}, 'rome.css')
      || die $template->error();

