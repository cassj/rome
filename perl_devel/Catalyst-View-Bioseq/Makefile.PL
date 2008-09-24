use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Catalyst::View::Bioseq',
    VERSION_FROM      => 'lib/Catalyst/View/Bioseq.pm', # finds $VERSION
    PREREQ_PM         => {
	Bio::Seq       => 0,
        GD             => 0,
        Catalyst::View => 0
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Catalyst/View/Bioseq.pm', # retrieve abstract from module
       AUTHOR         => 'Caroline Johnston <johnston@biochem.ucl.ac.uk>') : ()),
);
