package Codec::Encode;

use strict;
use warnings;
use constant {
	PLEN_MIN => 3,	# minimum length of pattern;
	EFF_MIN => 8
};

use feature qw/say/;
use Carp qw/croak/;
use Data::Dumper;

use Codec::JSON;

# constructer, defined some instance vars;
sub new {
	my $class = shift;
	my $JSON = Codec::JSON->new;
	my $bitmap = $JSON->import_bitmap;
	my $dpattern = $JSON->import_dpattern;

	my $self =
	{
		bitmap	=> $bitmap,
		dpattern => $dpattern,
		flags => {},
		@_,
	};

	return bless $self, $class;
}

# private
# generate bitpattern /[01]++/ from string;
sub gen_bitpattern {
	my $self = shift;
	chomp( my $text = shift );

	my $bitpattern = '';
	for( split //, $text ){
		$bitpattern .= $self->{bitmap}->{$_};
	}

	return $bitpattern;
};

# convert bitpattern to dice-pattern
my $str2dice = sub {
	my $self = shift;
	my $text = shift;
	my @search_index = qw/1 4 5 2 3 7 8 6 9/;

	my $dstr = '';
	my $bitpattern = $self->gen_bitpattern( $text );

	while( $bitpattern ){
		for( @search_index ){
			my $pattern = $self->{dpattern}->{$_};

			if( $bitpattern =~ s/^$pattern// ){
				$dstr .= $_;
				last;
			}
		}
	}

	return $dstr;
};

sub f2dstr {
    my $self = shift;
    my $filepath = shift
        or croak "filepath is not specified!";
    open FH, '<'.$filepath
        or croak "Cannot open file : $filepath\n";
    my $text = <FH>;
    close FH;

    return $self->$str2dice( $text );
}

# Accessor, generate dice arr;
sub gen_dstr {
	my $self = shift;
	my $text = shift;

	my $dstr = $self->$str2dice( $text );
	
	return $dstr;
}

# first logic end

# compression here
# private
# Create Patterns Hash, its so slow!!
my $CreatePHash = sub {
	my $self = shift;
	my $dstr = shift;

	my %patterns = ();

	for my $index ( 0 .. int( (length $dstr) / 2 ) ) {
		for my $plen ( PLEN_MIN .. ( length $dstr ) - $index ){
			my $pattern = substr( $dstr, $index, $plen );
			last if exists $patterns{$pattern};

			my $tmp = $dstr;
			my $pnum = $tmp =~ s/$pattern//g;
			last if $pnum <= 1;

			$patterns{$pattern} = $pnum;
		}
	}

	return %patterns;
};

# replace most efficient pattern
my $Replacement = sub {
	my $self = shift;
	my $dstr = shift;
	my $pmax = shift;

	my $delimiter = 'a';	# pattern 'a' is experimental;

	for( 1 .. $pmax ){
		my %phash = $self->$CreatePHash( $dstr );

		my @me = ( undef, -4 );

		for my $pattern ( keys %phash ){
			my $eff = ( (length $pattern) - 1 ) * ( $phash{$pattern} - 1 ) - 2;

			if( $me[1] < $eff ){
				@me = ( $pattern, $eff );
			}
		}

		return $dstr if $me[1] < EFF_MIN;
		
		my $mp = $me[0];
		my $Del = uc $delimiter;
		$dstr =~ s/$mp/$delimiter/g;
		$dstr =~ s/$delimiter/$Del/;

		$self->{flags}->{$Del} = $delimiter . $mp . $delimiter;
		++$delimiter;
	}
		
	return $dstr;
};

# restore preserved pattern
# like /[b-i]\d++[b-i]/
my $restorement = sub {
	my $self = shift;
	my $dstr = shift;

	for( keys %{$self->{flags}} ){
		my $pat = $self->{flags}->{$_};
		$dstr =~ s/$_/$pat/;
	}

	return $dstr;
};

# accessor, dice compression with Moving Window Algorithm;
sub DiceCompression {
	my $self = shift;
	my $dstr = shift;
	my $pmax = shift;
	$pmax //= 9;

	my $res = $self->$Replacement( $dstr, $pmax );
	my $resd = $self->$restorement( $res );

	return $resd;
}

# Woohoo!!
1;
