use 5.005;
use strict;
use ExtUtils::MakeMaker;

my %prereq = (
    "Test::More" => 0,
);

$prereq{"warnings::compat"} = 0 if $] < 5.006;

WriteMakefile(
    NAME            => 'constant',
    LICENSE         => 'perl',
    AUTHOR          => 'Sébastien Aperghis-Tramoni <sebastien@aperghis.net>',
    VERSION_FROM    => 'lib/constant.pm',
    ABSTRACT_FROM   => 'lib/constant.pm',
    INSTALLDIRS     => 'perl',
    PL_FILES        => {},
    PREREQ_PM       => \%prereq,
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean           => { FILES => 'constant-*' },
);
