#!/usr/bin/env perl
use inc::Module::Install;

name 'MooseX-Role-Pluggable';
all_from 'lib/MooseX/Role/Pluggable.pm';
githubmeta;

requires 'Class::MOP';
requires 'Moose';
requires 'Moose::Role';
requires 'Moose::Util::TypeConstraints';

test_requires 'Test::More';

auto_install;

WriteAll;
