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
my $dstr = read_file $ENV{HOME}.'/resource/ans' or croak "cannot open ans : $!";
my %flags = %{ decode_json( read_file $ENV{HOME}.'/resource/flags.json')};
my %rflags = %{mkflags( \%flags )};
my %dpattern = %{ decode_json( read_file $Bin.'/resource/dpattern.json' )};

# dice array is not compressed.
my $rawd = $encode->f2dstr( $filename );
# part of correct strings 
my $correct = substr $str, 0, $num;
# dice array of $correct
my $cd = $encode->gen_dstr( $correct );

my $i;
for( $i = 1;
	 substr( $rawd, 0, $i ) eq substr( $cd, 0, $i );
	 ++$i
 ){}

# my $rest = substr $rawd, 

say d2bp('a3');
say $dstr;
say $rawd;
say Dumper %rflags;
say $i;


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
			croak "search index is over limits!";
		}
	}
}
