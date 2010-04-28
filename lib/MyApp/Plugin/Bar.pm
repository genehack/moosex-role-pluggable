package MyApp::Plugin::Bar;
use Moose;
with 'MooseX::Role::Pluggable::Plugin';

sub bar    { return "Bar" }

__PACKAGE__->meta->make_immutable;
1;

