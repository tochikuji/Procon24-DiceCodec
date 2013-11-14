package Codec::Decode;

use strict;
use warnings;

use feature qw/say/;
use Carp qw/croak/;
use Data::Dumper;

use Codec::JSON;

# constructer
sub new {
	my $class = shift;
	my $JSON = Codec::JSON->new;
	my $bitmap = $JSON->import_bitmap;
	my $dpattern = $JSON->import_dpattern;

	my $self =
	{
		bitmap => $bitmap,
		dpattern => $dpattern,
		@_,
	};

	return bless $self, $class;
}

# decode from file
sub decode_file {
	my $self = shift;
	my $filepath = shift;
	croak "filepath is not specified!\n"
		unless defined $filepath;
	
	open FH, '<'.$filepath
		or croak "Cannot open file $filepath\n";
	chomp( my $dstr = <FH> );
	close FH;

	return $self->decode( $dstr );
}

# accessor, import compressed dstr from file
sub decode {
	my $self = shift;
	my $dstr = shift;

	# detect final delimiter
	my $delimiter;
	for( reverse( 'a' .. 'z' ) ){
		if( $dstr =~ m/$_/ ){
			$delimiter = $_;
			last;
		}
	}

	if( defined $delimiter ){
		# dice pattern flag
		my %flags = ();

		for( reverse( 'a' .. $delimiter ) ){
			$dstr =~ s/$_([^$_]+?)$_/$1/;
			$flags{$_} = $1;
		}

		for( reverse( 'a' .. $delimiter ) ){
			$dstr =~ s/$_/$flags{$_}/g;
		}
	}

	my $bitpattern = '';
	for( split //, $dstr ){
		$bitpattern .= $self->{dpattern}->{$_};
	}

	my $text = '';
	my %rbm = reverse %{$self->{bitmap}};
	
	# avoid substr out-of-range warning;
	no warnings;
	# mainloop; bitpattern -> raw;
	while(1){
		last unless $bitpattern;
		my $flag = 0;
		my $bp = substr $bitpattern, 0, 7;
		if( length $bp < 7 ){
			for( 1 .. 7 - length $bp ){ $bp .= '0' }
			$flag = 1;
		}

		$bitpattern = substr $bitpattern, 7;
		$text .= $rbm{$bp};
		last if $flag;
	}

	return $text;
}

1;

