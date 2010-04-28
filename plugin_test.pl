#! /opt/perl/bin/perl
use strict;
use warnings;

use lib './lib';
use MyApp;

my $app = MyApp->new_with_plugins({
  plugins => [
    'MyApp::Plugin::Foo' ,
    'MyApp::Plugin::Bar' ,
    'MyApp::Plugin::Baz' ,
  ] ,
});

foreach my $method ( qw/ foo bar baz common / ) {
  print uc($method),":\n";

  foreach my $plugin ( @{ $app->plugin_list }) {
    if ( $plugin->can( $method )) {
      printf "%s does %s: %s\n" , $plugin->name , $method , $plugin->$method;
    }
  }
  print "\n";
}
