use strict;
use warnings;

use feature qw/say/;
use FindBin qw/$Bin/;
use lib "$Bin".'/../lib';
use Data::Dumper;
use Parallel::ForkManager;
use IPC::Shareable;

use Codec::Encode;
use Codec::Decode;

my $encode = Codec::Encode->new;
my $decode = Codec::Decode->new;

my @scripts = glob $Bin."/scripts/*.txt";
my $flag = 0;

my $handle = tie( my $i = 0, 'IPC::Shareable', undef, { destroy => 1 } );
my $num = $ARGV[0];
$num //= 8;
my $pm = Parallel::ForkManager->new( $num );

foreach( @scripts ){
	$pm->start and next;

	open FH, $_ or warn "cannot open file : $_", next;
	chomp( my $src = <FH> );
	
	my $dstr = $encode->gen_dstr( $src );
	my $cstr = $encode->DiceCompression( $dstr );
	my $str = $decode->decode( $cstr );

	if( $str eq $src ){
		$handle->shlock;
		++$i;
		$handle->shunlock;
		say "$_ pass.\t".$i."/".(scalar @scripts);
	} else {
		say "failed $_";
		say $src;
		say $str;
		die;
	}

	$pm->finish;
}

$pm->wait_all_children; 

unless( $flag ){
	say "all ".scalar @scripts." tests passed.";
} else {
	say "$flag tests failed. abort;";
}
