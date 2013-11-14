use strict;
use warnings;
use feature qw/say/;
use HTTP::Lite;
use File::Slurp qw/read_file/;

my $ua = HTTP::Lite->new;
my $ans = read_file( $ARGV[0] ) or die;
my $var = {
	answer => $ans,
};

$ua->prepare_post( $var );

$ua->request( $ARGV[1] ) or die;

1;
