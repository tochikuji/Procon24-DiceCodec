use strict;
use warnings;
use feature qw/say/;

use LWP::UserAgent;
use HTTP::Request::Common qw/POST/;

my ( $interval, $tl, $url ) = @_;
$b_no //= '10';
$interval //= 30;
$tl //= 10;

my $tls = $tl * 60;
my $file_no = 1;

while( $tls > 0 ){
	my $filename = sprintf("%03d", $file_no++) . '.jpg';

	system( "./somescript $filename" );
	
	my $req = POST( 
		$url,
		Content_Type => 'form-data',
		Content => [ upload => [ $filename ] ],
	);

	my $ua = LWP::UserAgent->new;
	my $response = $ua->request( $req )->as_string;

	sleep $interval;
	$tls -= $interval;
}
