use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common qw/GET/;

my $ua = LWP::UserAgent->new;
my $res = $ua->get( $ARGV[1], ':content_file' => $ARGV[0] );
