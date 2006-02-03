package WebService::LastFM::SimilarArtists;
use strict;
use Cache::File;
use Carp;
use File::Path qw/mkpath/;
use LWP::Simple;
use URI::Escape;
use XML::Simple;

our $VERSION = '0.01';

sub new {
   my ($class, %parameters) = @_;

   my $self = bless ({}, ref ($class) || $class);
   my %options = (
      min_match  => 75,
      cache_time => '1 week',
      cache_dir  => '/tmp/lastfm.cache',
      %parameters,
   );

   $self->{'_options'} = \%options;

   # Check if the cache_dir exists
   if(!-d $self->{'_options'}->{'cache_dir'}) {
      eval { mkpath($self->{'_options'}->{'cache_dir'}) };
      if($@) {
	 Carp::croak("Couldn't create $self->{'_options'}->{'cache_dir'}:$@");
      }
   }

   return $self;
}

sub lookup {
   my ($self, $name) = @_;

   unless($name) {
      Carp::croak('No name supplied!');
      return;
   }
   
   my $cache = new Cache::File (
      cache_root => $self->{'_options'}->{'cache_dir'},
   );

   my $filename = $name;
      $filename =~ s/\W//g;
   my @info;
   @info = @{$cache->thaw($filename)} 
      if(ref $cache->thaw($filename) eq 'ARRAY');

   unless(@info) {
      my $data = get(sprintf("%s/%s/%s",
	             'http://ws.audioscrobbler.com/1.0/artist',
                      uri_escape($name),
	             'similar.xml')
                 );
      if($data) {
         my $xs   = new XML::Simple();
         my $x    = $xs->XMLin($data);

         if(ref $x->{'artist'} eq 'ARRAY') {
            foreach my $item (@{$x->{'artist'}}) {
	       next unless ref $item eq 'HASH';
               push @info, $item
	          if($item->{'match'} >= $self->{'_options'}->{'min_match'});
            }
            $cache->freeze($filename, \@info, 
                           $self->{'_options'}->{'cache_time'});
         }
      } else {
         Carp::carp("Couldn't fetch XML for $name");
         return ();
      }
   }
   return @info;
}

#------------------------------------------------------------------------------#
=head1 NAME

WebService::LastFM::SimilarArtists - Module to retrieve Related Artist 
information from audioscrobbler.net / last.fm

=head1 SYNOPSIS

  use strict;
  use WebService::LastFM::SimilarArtists;

  my $sa = WebService::LastFM::SimilarArtists->new(
              minmatch => 85,
	      cache_time => '1 week',
	      cache_dir  => '/var/cache/lastfm'
           );
  my @artists = $sa->lookup('Hate Forest');

  if(@artists) {
     print "<a href=\"$_->{'url'}\">$_->{'name'}</a> ".
           "(match: $_->{'match'})\n"
        foreach(@artists);
  }

=head1 DESCRIPTION

C<WebService::LastFM::SimilarArtists> retrieves Similiar Artists 
(Related Artists) information from L<http://audioscrobbler.net/> 
(L<http://last.fm/>), based on your input.

=head2 METHODS

=head3 new

C<new> creates a new WebService::LastFM::SimilarArtists object 
using the configuration passed to it.

=head4 options

=over 4

=item min_match

Specifies the minimal similarity match count that should be returned.
Defaults to C<75>.

=item cache_time

Specifies the time the query should be cached to prevent hammering
the audioscrobbler website. Webmaster suggested one week, which is
the default.

Time can be specified in the same manner as with L<Cache::File>. It can
be set using seconds since the epoch, or using a slightly more readable
form of e.g. '1 week', '2 months', etc. Valid units are s, second, 
seconds, sec, m, minute, minutes, min, h, hour, hours, w, week, weeks, 
M, month, months, y, year and years. You can also specify an 
absolute time, such as '16 Nov 94 22:28:20' or any other time that 
Date::Parse can understand.

=item cache_dir

Specifies the root directory for the caching. Defaults to 
C</tmp/lastfm.cache>. Directories are created when
needed. The module will C<croak> when it fails to create a
directory.

=back

=head3 lookup

Takes one argument, the band or artist to be queried. This
method returns an array of anonymous hashes with the similar 
artists found (if any).

=head2 RETURN VALUES

The array returned contains anonymous hashes with the following 
information:

=over 4

=item name

The artist/band name

=item mbid

The Musicbrainz ID (if available)

=item match

The similarity match count (on a scale of 0 to 100)

=item url

The URL to the artist's page at L<http://last.fm/>

=item streamable

Whether the artist is "streamable", meaning, whether the rightholders
of artist's work have submitted tracks to L<http://last.fm/>.

1 for true, 0 for false.

=back

=head1 BUGS

Please report any found bugs to
L<http://rt.cpan.org/Public/Dist/Display.html?Name=WebService-LastFM-SimilarArtists> or contact the author.

=head1 AUTHOR

M. Blom, 
E<lt>blom@cpan.orgE<gt>, 
L<http://menno.b10m.net/perl/>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

B<NOTE>: The datafeed from audioscrobbler.net is for
I<non-commercial use only>. Please see 
L<http://www.audioscrobbler.net/data/webservices/> for
more licensing information.

=head1 SEE ALSO

=over 4

=item * L<http://www.last.fm/>

=item * L<http://www.audioscrobbler.net/>

=item * L<http://www.audioscrobbler.net/data/webservices/>

=item * L<http://www.musicbrainz.org/>

=item * L<Cache::File>, L<LWP::Simple>, L<URI::Escape>, L<XML::Simple>

=item * L<WebServices::LastFM>

=back

=cut

1;
