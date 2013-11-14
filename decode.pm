use strict;
use warnings;

use feature qw/say/;
use FindBin::libs;
use JSON qw/encode_json/;

use Codec::JSON;
use Codec::Decode;

my $obj = Codec::Decode->new;

my $text = $obj->decode_file( $ARGV[0] );

unless( defined $ARGV[1] ){
	say $text;
} else {
	open FH, '>'.$ARGV[1] or die "Cannot open file : $!\n";
	print FH $text;
	close FH;
}

