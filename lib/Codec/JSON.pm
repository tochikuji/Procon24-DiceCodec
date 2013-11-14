package Codec::JSON;

use strict;
use warnings;

use Carp qw/croak/;
use feature qw/say/;
use constant {
	RESOURCES_PATH => './resource/',
};

use File::Slurp;
use JSON qw/decode_json/;

# Constructer
sub new {
	my $class = shift;
	my $self = { @_ };

	return bless $self, $class;
}

# common logic, convert json to hash reference;
my $load_json = sub {
	my $self = shift;
	my $json_str = shift;

	my $res = decode_json $json_str;

	return $res;
};

# for bitmap.json
sub import_bitmap {
	my $self = shift;
	my $filename = shift;
	my $json_path = defined $filename ? RESOURCES_PATH . $filename : RESOURCES_PATH . 'bitmap.json';

	my $bitmap_str = File::Slurp::read_file $json_path;
	my $bitmap = $self->$load_json( $bitmap_str );

	return $bitmap;
}

# for dpattern.json
sub import_dpattern {
	my $self = shift;
	my $filename = shift;
	my $json_path = defined $filename ? RESOURCES_PATH . $filename : RESOURCES_PATH . 'dpattern.json';
	
	my $dpattern_str = File::Slurp::read_file $json_path;
	my $dpattern = $self->$load_json( $dpattern_str );

	return $dpattern;
}

# perl module must return true value;
1;
