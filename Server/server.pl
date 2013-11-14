use Mojolicious::Lite;
use FindBin qw/$Bin/;
use Data::Dumper;
use File::Basename;
use File::Spec;

my $data = File::Spec->catdir(File::Basename::dirname(__FILE__), '');
push @{app->static->paths}, $data;
app->log->level('debug');

my $snum = '000';

get '/' => 'form';

post '/upload' => sub {
	my $self = shift;

	return $self->render(text => 'File is too big.', status => 200)
		if $self->req->is_limit_exceeded;

	return $self->redirect_to('form')
		unless my $file = $self->param('upload');

	my $size = $file->size;
	my $name = $file->filename;
	say $file->filename . ' size: ' .$file->size;
	$file->move_to( './image/'.'00_'.++$snum.'.jpg' );
	say "save as 00_$snum.jpg";
	$self->render( text => "Thanks for uploading $size byte file $name." );
};

app->start;
__DATA__

@@ form.html.ep
<!DOCTYPE html>
<html>
<head><title>Upload</title></head>
<body>
%= form_for upload => (enctype => 'multipart/form-data') => begin
%= file_field 'upload'
%= submit_button 'Upload'
% end
</body>
</html>
