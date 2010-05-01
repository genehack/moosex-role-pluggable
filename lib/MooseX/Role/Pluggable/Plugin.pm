package MooseX::Role::Pluggable::Plugin;
use Moose::Role;
use Moose::Util::TypeConstraints;

has name => (
  isa => 'Str' ,
  is  => 'ro' ,
  required => 1 ,
);

subtype 'MooseXRolePluggable'
  => as 'Object'
  => where { $_->does( 'MooseX::Role::Pluggable' ) }
  => message { 'Parent does not consume MooseX::Role::Pluggable!' };

has parent => (
  isa      => 'MooseXRolePluggable' ,
  is       => 'ro' ,
  required => 1 ,
);

no Moose::Role;
1;

