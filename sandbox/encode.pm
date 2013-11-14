use strict;
use warnings;
use JSON qw/decode_json encode_json/;
use bignum ( 'precision', -500);
use File::Slurp;
use Data::Dumper;
use feature qw/say/;
use List::Util qw/shuffle/;
use Parallel::ForkManager;

sub round($);
sub makehash;

my $pm = Parallel::ForkManager->new( 6 );

for(1..1000){
# my $json = File::Slurp::read_file( './numerics.json' );
	$pm->start and next;
	say;
	my $json = makehash;
	my $hash = decode_json( $json );
	chomp( my $str = File::Slurp::read_file( $ARGV[0] ) );

	my $numeric = '';
	foreach( split //, $str ){
		$numeric .= $hash->{$_};
	}

	my @diff = ();
	my $num = $numeric + 0.0;
	say $num;
	say length $num;


	while( $num != 1 ){
		my $tmp = $num;
		my $sq = sqrt( $num );
		$num = int $sq;
		push @diff, $tmp - $num ** 2;
	}
	say join ',', @diff;
	say length (join ',', @diff );
	say '';
	$pm->finish;
}

$pm->wait_all_children;

sub makehash {
	my $chars = '!"#$%^\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz&';
	my %hash = ();
	my $i = '10';
	for( shuffle( split //, $chars ) ){
		$hash{$_} = $i++;
	}

	return encode_json \%hash;
}

