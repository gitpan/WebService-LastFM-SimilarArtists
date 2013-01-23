# -*- perl -*-

# t/002_online_query.t - lookup Anaal Nathrakh
#                        It really always should return Fukpig.

use Test::More tests => 3;

use strict;
use File::Path;
use WebService::LastFM::SimilarArtists;

my $sa = WebService::LastFM::SimilarArtists->new;
isa_ok($sa, 'WebService::LastFM::SimilarArtists');

my @artists = $sa->lookup('Anaal Nathrakh');
cmp_ok(@artists, '>', 0, 'Results received');

ok( grep ( $_->{name} eq 'Fukpig', @artists), 'Fukpig found' );

END {
   rmtree('/tmp/lastfm.cache', 0, 0);
}
