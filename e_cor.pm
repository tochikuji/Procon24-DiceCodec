use strict;
use warnings;
use feature qw/say/;

use FindBin::libs;
use Codec::Encode;
use Codec::Decode;

use Carp qw/croak/;
use File::Slurp qw/read_file/;
use JSON qw/decode_json/;
use Data::Dumper;
use FindBin qw/$Bin/;

sub mkflags($);
sub search_cindex($);
sub d2bp($);

my ( $filename, $num ) = @ARGV;

my $encode = Codec::Encode->new;
my $decode = Codec::Decode->new;

chomp( my $str = read_file $filename );

# compressed dice string
my $dstr = read_file $ENV{HOME}.'/resource/ans' or croak "cannot open ans : $!";
# raw dice string
my $rawd = read_file $ENV{HOME}.'/resource/dans' or croak "cannot oprn dans : $!";
# dice pattern flags
my %flags = %{ decode_json( read_file $ENV{HOME}.'/resource/flags.json')};
# dice pattern flags is valid
my %rflags = %{mkflags( \%flags )};
# dice map bitmap to dice
my %dpattern = %{ decode_json( read_file $Bin.'/resource/dpattern.json' )};

# raw dice string from problem
my $rawd_np = $encode->f2dstr( $filename );
# correct string made by av num
my $correct = substr $str, 0, $num;
# raw dice string from correct case
my $cd = $encode->gen_dstr( $correct );

my $corr_index = [undef, undef];

if( $rawd_np =~ m/^$cd/ ){
	my $d_dest = '';
	$rawd_np =~ s/^$cd(\d++)$/$1/;
	for(my $i = 0; ( length d2bp($d_dest) ) < 7; ++$i ){
		$d_dest = substr $rawd_np, 0, $i;
	}
	
	$corr_index->[0] = length $cd;
	$corr_index->[1] = $d_dest;
} else {
	my $i;
	for( $i = 1;
		 substr($rawd_np, 0, $i) eq substr($cd, 0, $i);
		 ++$i ){}
	$corr_index->[0] = $i;

	my $margin = length( d2bp( substr $rawd_np, 0, $i ) ) % 7;
	my $d_dest = '';

	for( my $j = 0; ( length d2bp($d_dest) ) < 7 - $margin; ++$j ){
		$d_dest = substr $rawd_np, $i, $j;
	}
	$corr_index->[1] = $d_dest;
}

if( substr( $dstr, search_cindex($corr_index->[0]), length $corr_index->[1] ) =~ m/[a-z]/ ){
	say '-1';
	say $corr_index->[0];
} else {
	say search_cindex( $corr_index->[0] );
	say $corr_index->[1];
}

sub mkflags($){
	my $flags = shift;
	my $rf = {};

	my $delimiter = 'a';

	for( keys %{$flags} ){
		my $del = lc $_;
		$delimiter = $del if $del gt $delimiter;
		$flags->{$_} =~ s/^$del(.+?)$del$/$1/;
		$rf->{$del} = $flags->{$_};
	}

	if( defined $delimiter ){
		for( reverse( 'a' .. $delimiter ) ){
			$rf->{$_} =~ s/([a-z])/$rf->{$1}/g;
		}
	}

	return $rf;
}


sub d2bp($) {
	my $dice = shift;
	my $bit = '';

	for( split //, $dice ){
		$bit .= $dpattern{$_};
	}

	return $bit;
}

sub search_cindex($) {
	my $index = shift;
	my $t_dstr = $dstr;
	
	# detect final delimiter
	my $delimiter;
	for( reverse( 'a' .. 'z' ) ){
		if( $t_dstr =~ m/$_/ ){
			$delimiter = $_;
			last;
		}
	}

	# replace first registaion pattern to be not delimited pattern
	if( defined $delimiter ){
		for( reverse( 'a' .. $delimiter ) ){
			$t_dstr =~ s/$_([^$_]+?)$_/0${1}0/;
		}
	}

	my @comp = split //, $t_dstr;

	my $i = -1;
	my $j = -1;
	for( @comp ){
		if( m/\d/ ){
			++$i if $_ ne '0';
		} else {
			$i += length $rflags{$_};
		}
		++$j;

		if( $i == $index ){
			return $j;
		} elsif( $i > $index ){
			return $j;
		}
	}
}
