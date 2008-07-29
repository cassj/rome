#!/usr/bin/perl 

# Script to generate the ROME menu from nav.yml
# run from the ROME directory, like:
#
#    script/rome_makenav.pl 

#there has to be a nicer way of doing this...

use strict;
use lib 'lib/';

use YAML;
use File::Copy;
use Path::Class;

my $nav = YAML::LoadFile('nav.yml');
my $config = YAML::LoadFile('rome.yml');

# this should only occur in root
my $nav_tt_file = file('root','src','site','nav');

copy($nav_tt_file, "$nav_tt_file.bkup") or die "couldn't copy $nav_tt_file";

open(FILE, ">$nav_tt_file") or die "Couldn't open $nav_tt_file for writing";

#start the menu div and list
print FILE qq| <ul id="nav_list">\n|;

&make_tt($nav);

sub make_tt{
  my $list = shift;

  #we have an array of hashes:
  foreach my $element (@$list){
    
    #grab your hash key
    my ($key) = keys %$element;

      #If this is a submenu
      if ($element->{$key}->{dropdown}){

        print FILE "\n";

        #add any roles checks
	if ($element->{$key}->{roles}){
          print FILE '[% IF '; 
          print FILE  join (' or ', 
			    map {qq|Catalyst.check_user_roles('$_')|}
			    @{$element->{$key}->{roles}}
			     );
          print FILE "%]\n";

	}

        #start the sublist
        print FILE qq|  <li><a title="|
          .$element->{$key}->{title}
	    .qq|" href="#" class="dropdown">|
	      .$key
		."</a>\n";
        print FILE "   <ul>\n";

        # and generate the submenu
        &make_tt($element->{$key}->{dropdown});
        
        print FILE "   </ul>\n";
        print FILE "  </li>\n";

        #close your role check
	 print FILE qq|[% END %]\n| if ($element->{$key}->{roles});
      }
      else {
        #make a regular link
	my $name = $element->{$key}->{display_name} || $key;
	my $component = $element->{$key}->{component};
	my $version = $element->{$key}->{version};
	my $process = $element->{$key}->{process};
	my $href = $element->{$key}->{href};
	$href = "component/$component/$process" unless $href;
	my $title = $element->{$key}->{title};
        my $any_datatype = $element->{$key}->{any_datatype};
	
	print FILE qq|    <li><a class=|; 

	if ($any_datatype){
	  print FILE q|"active"|; 
	}
	else{
	  print FILE qq| [% IF Catalyst.session.active_processes.processes.$component.item('$version').$process %]
                           "active"
                         [% ELSE %]
                           "inactive"
                         [% END %] |;
	}
	
	print FILE qq|title="$title"|
	  .qq| href="$href">|
	    .qq|$name|
	      .qq|</li></a>\n|;
      }
  }

}

#end the menu list and div
print FILE qq| </ul>\n|;


close(FILE) or die "Couldn't close file $nav_tt_file";

print "\nDone!\n";
