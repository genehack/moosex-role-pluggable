package MyApp::Plugin;
use Moose;
with 'MooseX::Role::Pluggable::Plugin';
sub common { return "Common" }

__PACKAGE__->meta->make_immutable;
1;
