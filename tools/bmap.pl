use strict;
use warnings;
use JSON qw/decode_json/;
use File::Slurp qw/read_file/;
use feature qw/say/;

my $bjson = read_file( '../resource/bitmap.json' );
my $djson = read_file( '../resource/dpattern.json' );

my %bitmap = %{decode_json $bjson};
my %dpat = %{decode_json $djson};

my @search_index = qw/1 4 5 2 3 7 8 6 9/;
for my $char ( keys %bitmap ){
	my $bp = $bitmap{$char};
	my $dstr = '';

	while( $bp ne '' ){
		for my $dice( @search_index ){
			my $pat = $dpat{$dice};
			if( $bp =~ m/^$pat/ ){
				$dstr .= $dice;
				$bp =~ s/^$pat//;
				last;
			}
		}
	}
	
	say "$char : $dstr";
}

