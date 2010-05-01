#!/usr/bin/env perl
use inc::Module::Install;

name 'MooseX-Role-Pluggable';
all_from 'lib/MooseX/Role/Pluggable.pm';

requires 'Class::MOP';
requires 'Moose::Role';

test_requires 'Test::More';

auto_install;

WriteAll;
