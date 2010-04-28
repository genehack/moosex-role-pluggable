package MyApp;
use Moose;
use namespace::autoclean;
with 'MooseX::Role::Pluggable';

__PACKAGE__->meta->make_immutable;
1;
