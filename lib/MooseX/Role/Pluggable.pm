package MooseX::Role::Pluggable;
use Class::MOP;
use Moose::Role;
use Moose::Util::TypeConstraints;
use 5.010;

our $VERSION = 0.01;

has plugins => (
  isa => 'ArrayRef[Str]',
  is  => 'rw' ,
);

subtype 'MooseXRolePluggablePlugin'
  => as 'Object'
  => where { $_->does( 'MooseX::Role::Pluggable::Plugin' ) }
  => message { 'Plugin did not consume the required role!' };

has plugin_hash => (
  isa        => 'Maybe[HashRef[MooseXRolePluggablePlugin]]' ,
  is         => 'ro' ,
  init_arg   => undef ,
  lazy_build => 1 ,
);

sub _build_plugin_hash {
  my $self = shift;

  return $self->plugin_list ? { map { $_->name => $_ } @{ $self->plugin_list } } : undef;
}

has plugin_list => (
  isa        => 'Maybe[ArrayRef[MooseXRolePluggablePlugin]]' ,
  is         => 'ro' ,
  init_arg   => undef ,
  lazy_build => 1 ,
);

sub _build_plugin_list {
  my( $self ) = shift;

  return undef unless $self->plugins;

  my $plugin_list = [];

  my $plugin_name_map = $self->_map_plugins_to_libs();

  foreach my $plugin_name ( keys %$plugin_name_map ) {
    my $plugin_lib = $plugin_name_map->{$plugin_name};

    ### FIXME should have some Try::Tiny here, with a parameter to control
    ### what happens when a class doesn't load -- ignore, warn, die
    Class::MOP::load_class( $plugin_lib );

    my $plugin = $plugin_lib->new({
      name   => $plugin_name ,
      parent => $self ,
    });

    push @{ $plugin_list } , $plugin;
  }

  return $plugin_list;
};

sub _map_plugins_to_libs {
  my( $self ) = @_;
  my $class = ref $self;

  my %map;
  foreach ( @{ $self->plugins } ) {
    $map{$_} = ( s/^\+// ) ? $_ : "${class}::Plugin::$_";
  }
  return \%map;
}

no Moose::Role;
1;
