# -*- perl -*-

# t/002_online_query.t - lookup Hate Forest. 
#                        It really always should return Drudkh.

$|++;
use Test::More tests => 3;

use strict;
use File::Path;
use WebService::LastFM::SimilarArtists;

my $sa = WebService::LastFM::SimilarArtists->new();
isa_ok($sa, 'WebService::LastFM::SimilarArtists');

my @artists = $sa->lookup('Hate Forest');

cmp_ok(@artists, '>', 0, 'Results received');

my $drudkh = 0;

foreach(@artists) {
   $drudkh++ if($_->{'name'} eq 'Drudkh'); 
}

cmp_ok($drudkh, '>', 0);

END {
   rmtree('/tmp/lastfm.cache', 0, 0);   
}
