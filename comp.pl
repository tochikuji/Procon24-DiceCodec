use strict;
use warnings;
use feature qw/say/;

use FindBin::libs;
use Codec::Encode;
use Codec::Decode;
use File::Slurp qw/read_file/;

my ( $filename, $num ) = @ARGV;

my $problem = read_file( $filename );
my $dstr = read_file( $ENV{HOME}.'/resource/ans' );
my $ans = substr $dstr, 0, $num;
my $res = Codec::Decode->new->decode( $ans );

my $i;
for( $i = 0; substr($res, 0, $i) eq substr($problem, 0, $i);++$i){}

say $i - 1;
