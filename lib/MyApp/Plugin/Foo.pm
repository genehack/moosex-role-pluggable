package MyApp::Plugin::Foo;
use Moose;
extends 'MyApp::Plugin';

sub foo { return "Foo" }

__PACKAGE__->meta->make_immutable;
1;

