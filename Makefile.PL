use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	=> 'constant',
    'VERSION_FROM' => 'constant.pm', # finds $VERSION
    'dist'	=> { COMPRESS=>'gzip', SUFFIX=>'gz' }
);
