use strict;
use warnings;
use feature qw/say/;

use LWP::UserAgent;
use HTTP::Request::Common qw/POST/;

my ( $filename, $url ) = @ARGV;

my $req = POST(
	$url,
	Content_Type => 'form-data',
	Content => [upload => [$filename] ],
);

my $ua = LWP::UserAgent->new;
my $res = $ua->request( $req )->as_string;

say $res;
