use strict;
use warnings;

use feature qw/say/;
use FindBin::libs;
use File::Slurp qw/read_file write_file/;
use JSON qw/encode_json/;

use Codec::Encode;
use Codec::JSON;
use Data::Dumper;

my $obj = Codec::Encode->new;

my $dstr = $obj->f2dstr( $ARGV[0] );

my $darr =  $obj->DiceCompression( $dstr );

say Dumper $obj->{flags};

write_file $ENV{HOME}.'/resource/dans', $dstr;
write_file $ENV{HOME}.'/resource/flags.json', encode_json $obj->{flags};
write_file $ENV{HOME}.'/resource/ans', $darr;
