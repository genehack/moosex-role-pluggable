package MooseX::Role::Pluggable::Plugin;
use Moose::Role;

has name => (
  isa => 'Str' ,
  is  => 'ro' ,
  required => 1 ,
);

### FIXME add in constraints here to make sure
### $parent->does( 'MooseX::Role::Pluggable' )
has parent => (
  isa => 'Object' ,
  is  => 'ro' ,
  required => 1 ,
);

no Moose::Role;
1;
