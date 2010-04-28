package MyApp::Plugin::Baz;
use Moose;
extends 'MyApp::Plugin';

sub baz    { return "Baz" }

__PACKAGE__->meta->make_immutable;
1;
