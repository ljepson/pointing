package Pointing::Controller::_Base;

use strict;
use warnings;

use Moo;
use Method::Signatures;
use namespace::clean;

extends qw(Mojolicious::Controller);

has 'app' => (
    is => 'ro',
);

1;
