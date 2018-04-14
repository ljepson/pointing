package Pointing::Controller::Hello;

use strict;
use warnings;

use Method::Signatures;
use Moo;
use namespace::clean;

extends qw(Pointing::Controller::_Base);

method hello ($c:) {
    $c->openapi->valid_input or return;

    $c->render_later;

    $c->delay(
        sub {
            $c->render(openapi => { hello => time });
        }
    );
}

1;
