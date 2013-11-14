use strict;
use warnings;
use feature qw/say/;
use FindBin::libs;
use HTTP::Lite;
use LWP::UserAgent;
use Data::Dumper;
use HTTP::Request::Common qw/POST/;

use constant {
	USER_TOKEN => '1344445285',
};

use Codec::JSON;
use Codec::Decode;

my $obj = Codec::Decode->new;
my $ua = LWP::UserAgent->new;
my $text = $obj->decode_file( $ARGV[0] );

my $var = {
	PlayerIDFieldName => USER_TOKEN,
	AnswerFieldName => $text,

};

# my $var = {
# 	playerid => USER_TOKEN,
# 	answer => $text,
# 
# };

my $res = $ua->post( $ARGV[1], $var )->as_string;
say Dumper $res;

1;
