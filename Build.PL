use strict;
use Module::Build;

my %prereq = (
    "Test::More" => 0,
);

$prereq{"warnings::compat"} = 0 if $] < 5.006;

my $builder = Module::Build->new(
    module_name         => 'constant',
    license             => 'perl',
    dist_author         => 'Sébastien Aperghis-Tramoni <sebastien@aperghis.net>',
    dist_version_from   => 'lib/constant.pm',
    installdirs         => 'core',
    build_requires      => \%prereq,
    add_to_cleanup      => [ 'constant-*' ],
);

$builder->create_build_script();
