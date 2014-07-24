package MooseX::Role::Pluggable;
# ABSTRACT: add plugins to your Moose classes
use Class::MOP;
use Moose::Role;
use Moose::Util::TypeConstraints;
use Tie::IxHash;
use 5.010;

has plugins => (
  isa => 'ArrayRef[Str] | HashRef',
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

    my $plugin;
    if ( ref $self->plugins eq 'ARRAY' ) {
      $plugin = $plugin_lib->new({
        name   => $plugin_name ,
        parent => $self ,
      });
    } else {
      my $args = $self->plugins->{$plugin_name} || {};
      die "'name' is used internally and cannot be passed to constructor" if exists $args->{name};
      die "'parent' is used internally and cannot be passed to constructor" if exists $args->{parent};
      $args->{name} = $plugin_name;
      $args->{parent} = $self;

      $plugin = $plugin_lib->new($args);
    }

    push @{ $plugin_list } , $plugin;
  }

  return $plugin_list;
};

sub plugin_run_method {
  my( $self , $method ) = @_;

  my $return = [];
  foreach my $plugin ( @{ $self->plugin_list }) {
    if ( $plugin->can( $method ) ) {
      push @$return , $plugin->$method();
    }
  }
  return $return;
}

sub _map_plugins_to_libs {
  my( $self ) = @_;
  my $class = ref $self;

  tie my %map, "Tie::IxHash";
  my @plugins = ref $self->plugins eq 'ARRAY' ? @{ $self->plugins } : keys %{ $self->plugins };
    
  foreach ( @plugins ) {
    $map{$_} = ( s/^\+// ) ? $_ : "${class}::Plugin::$_";
  }
  return \%map;
}

no Moose::Role;
1;

__END__

=head1 NAME

MooseX::Role::Pluggable - add plugins to your Moose classes

=head1 SYNOPSIS

    package MyMoose;
    use Moose;
    with 'MooseX::Role::Pluggable';

    my $moose = MyMoose->new({
      plugins => [ 'Antlers' , 'Tail' , '+After::Market::GroundEffectsPackage' ] ,
      # other args here
    });

    or

    my $moose = MyMoose->new({
      plugins  => {
        'Antlers' => {
          long => 1,
        },
        'Tail' => {
          short => 1,
        },
        '+After::Market::GroundEffectsPackage' => {},
      }
    });

    foreach my $plugin ( @{ $moose->plugin_list } ) {
      if ( $plugin->can( 'some_method' )) {
        $plugin->some_method();
      }
    }

    # call a method in a particular plugin directly
    # (plugin_hash() returns a hash ref of 'plugin_name => plugin')
    $moose->plugin_hash->{Antlers}->gore( $other_moose );

    # plugins are indexed by the name that was used in the original 'plugins' list
    $moose->plugin_hash->{After::Market::GroundEffectsPackage}->light_up();

    # see the documentation for MooseX::Role::Pluggable::Plugin for info on
    # how to write plugins...

=head1 DESCRIPTION

This is a role that allows your class to consume an arbitrary set of plugin
modules and then access those plugins and use them to do stuff.

Plugins are loaded based on the list of plugin names in the 'plugins'
attribute. Names that start with a '+' are used as the full name to load;
names that don't start with a leading '+' are assumed to be in a 'Plugins'
namespace under your class name. (E.g., if your app is 'MyApp', plugins will
be loaded from 'MyApp::Plugin').

NOTE: Plugins are lazily loaded -- that is, no plugins will be loaded until
either the 'plugin_list' or 'plugin_hash' methods are called. If you want to
force plugins to load at object instantiation time, your best bet is to call
one of those method right after you call 'new()'.

Plugin classes should consume the 'MooseX::Role::Pluggable::Plugin' role; see
the documentation for that module for more information.

=head1 METHODS

=head2 plugin_hash

Returns a hashref with a mapping of 'plugin_name' to the actual plugin object.

=head2 plugin_list

Returns an arrayref of loaded plugin objects. The arrayref will have the
same order as the plugins array ref passed in during object creation.

=head2 plugin_run_method( $method_name )

Looks for a method named $method_name in each plugin in the plugin list. If a
method of given name is found, it will be run. (N.b., this is essentially the
C<foreach> loop from the L</SYNOPSIS>.)

=head1 AUTHOR

John SJ Anderson, C<genehack@genehack.org>

=head1 CONTRIBUTORS

Sean Maguire C<smaguire@talktalkplc.com>

=head1 SEE ALSO

L<MooseX::Role::Pluggable::Plugin>, L<MooseX::Object::Pluggable>,
L<Object::Pluggable>

=head1 COPYRIGHT AND LICENSE

Copyright 2014, John SJ Anderson

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
