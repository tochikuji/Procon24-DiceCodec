use Mojolicious::Lite;
use File::Slurp qw/read_file write_file/;

my $kaito = '001';

sub check_cornum {
	chomp( my $str = read_file( $ARGV[0] ) );
	my $len = length $str;

	my @ans = split //, $_[0];
	my @cor = split //, $str;

	my $glen = length $str;
	my $i;

	for( $i = 0; $i < $glen;++$i ){
		last unless $ans[$i] eq $cor[$i];
	}

	return "$i / $glen";
}

write_file ('ans.tmp', check_cornum(' ') );

get '/' => 'index';
post '/answer' => sub {
	my $self = shift;
	my $ans = $self->param('answer');
	say $kaito++ . "/100";
	die if $kaito == 100;

	write_file ('ans.tmp', check_cornum($ans)."\n$ans" );

	$self->redirect_to('index');

};

app->start;

__DATA__

@@ index.html.ep
<html>
  <head><title>Top Page</title></head>
  <body>
    <form method="post" action="<%= url_for '/answer' %>" >
      <div>Title: <input type="text" name="answer"></div>
      <div><input type="submit" value="Send"></div>
    </form>
  </body>
</html>
