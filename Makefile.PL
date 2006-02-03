

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'WebService::LastFM::SimilarArtists',
    VERSION_FROM => 'lib/WebService/LastFM/SimilarArtists.pm', # finds \$VERSION
    AUTHOR       => 'M. Blom (blom@cpan.org)',
    ABSTRACT     => 'Module to retrieve Related Artist information from audioscrobbler.net (last.fm)',
    PREREQ_PM    => {
                     'Cache::File'  => 0,
                     'Carp'         => 0,
                     'File::Path'   => 0,
                     'LWP::Simple'  => 0,
                     'URI::Escape'  => 0,
                     'XML::Simple'  => 0,
                     'Test::Simple' => 0,
                    },
);
