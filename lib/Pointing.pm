package Pointing;

use Moo;
use Method::Signatures;
use JSON;

extends 'Mojolicious';

method startup ($app:) {
    # Load swagger API definition
    $app->plugin(OpenAPI => {
        url => $app->home->rel_file('conf/swagger.yaml'),
        log_level => 'debug',
    });

    # App Secret used for signed cookies
    require Mojo::File;
    (my $app_secret = Mojo::File::slurp($app->home->rel_file('conf/app.secret'))) =~ s/\n$//;

    $app->secrets([$app_secret]);

    $app->renderer->default_format('json');

    # This is temporary and shouldn't be rolled to production. This is needed by the tools-client to be able to POST/PUT/DELETE
    $app->hook(before_dispatch => sub {
        my $c = shift;

        # Stop processing if we are in a production environment
        return if ($app->mode || $ENV{'MOJO_MODE'} || 'production') eq 'production';

        $c->res->headers->header('Access-Control-Allow-Origin' => '*');
        $c->res->headers->header('Access-Control-Allow-Headers' => 'origin, content-type, accept');
    });

    $app->hook(after_render => sub {
        my ($c, $output) = @_;

        # Only perform the response encapsulation for paths beginning with /api
        return unless $c->req->url->path->parts->[0] eq 'api';

        my $json = eval { from_json $$output };

        # OpenAPI already handled this response
        return if $@ || (ref $json eq 'HASH' && $json->{'errors'});

        my $data = {
            status => $c->stash->{'status'} || 200,
        };

        # Looking for data structures that aren't hashes or are, but don't have a child key of data
        if ( ref $json ne 'HASH' || ( ref $json eq 'HASH' && ! $json->{'data'} )) {
            $data->{'data'} = $json;
        }

        $$output = to_json $data;
    });
}

1;

__END__
