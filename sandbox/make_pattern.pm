use common::sense;
use JSON qw/encode_json/;
use File::Slurp;

my $chars = '!"#$%^\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ_`abcdefghijklmnopqrstuvwxyz&';
say $chars;
say length $chars;
my %hash = ();
my $i = '10';
for( split //, $chars ){
	$hash{$_} = $i++;
}

File::Slurp::write_file( './numerics.json', encode_json(\%hash) );
