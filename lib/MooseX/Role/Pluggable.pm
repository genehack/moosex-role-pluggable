package MooseX::Role::Pluggable;
use Moose::Role;
use Class::MOP;

has plugin_list => (
  isa => 'ArrayRef[MooseX::Role::Pluggable::Plugin]' ,
  is  => 'ro' ,
  init_arg => undef ,
  default => sub { [] } ,
);

has plugins => (
  isa => 'ArrayRef[Str]',
  is  => 'rw' ,
  default => sub { [] } ,
);

sub new_with_plugins {
  my( $class , $args ) = @_;

  my $self = $class->new( $args );
  $self->load_plugins;
}

sub load_plugins {
  my( $self ) = shift;

  ### FIXME plugins should handle the standard "append a prefix unless name
  ### starts with '+'" behavior
  foreach my $plugin_class ( @{ $self->plugins }) {
    Class::MOP::load_class( $plugin_class );

    my $plugin = $plugin_class->new({
      name   => $plugin_class ,
      parent => $self ,
    });

    push @{ $self->{plugin_list} } , $plugin;
  }

  return $self;
};

no Moose::Role;
1;
