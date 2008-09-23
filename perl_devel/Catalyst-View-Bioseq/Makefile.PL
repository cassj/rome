use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Catalyst::View::Bioseq',
    AUTHOR              => 'Caroline Johnston <johnston@biochem.ucl.ac.uk>',
    VERSION_FROM        => 'lib/Catalyst/View/Bioseq.pm',
    ABSTRACT_FROM       => 'lib/Catalyst/View/Bioseq.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        "Bio::Seq" => 0,
        "Catalyst" => 0,
        "Catalyst::Plugin::SubRequest" => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Catalyst-View-Bioseq-*' },
);
