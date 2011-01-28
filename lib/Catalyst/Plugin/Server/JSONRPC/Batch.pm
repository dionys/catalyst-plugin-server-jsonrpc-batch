package Catalyst::Plugin::Server::JSONRPC::Batch;

use strict;
use warnings;

BEGIN {
    use Class::MOP;

    my $class = 'JSON::RPC::Common::Procedure::Call';

    unless (Class::MOP::is_class_loaded($class)) {
        Class::MOP::load_class($class);
    }

    my $meta = $class->meta;

    $meta->make_mutable();
    $meta->add_around_method_modifier(
        'inflate',
        sub {
            my ($method, $class, @args) = @_;

            if (@args == 1 && ref($args[0]) eq 'ARRAY') {
                return $class->new_from_data(
                    'jsonrpc' => '2.0',
                    'id'      => scalar(time()),
                    'method'  => $Catalyst::Plugin::Server::JSONRPC::Batch::Method,
                    'params'  => $args[0]
                );
            }
            else {
                return $method->($class, @args);
            }
        }
    );
    $meta->make_immutable();
}


our $Method = 'system.handle_batch';


sub setup_engine {
    my $class = shift();

    $class->server->jsonrpc->add_private_method(
        $Method => sub {
            my ($c, @args) = @_;

            # HACK: Store values.
            my $body = $c->req->_body;
            my $path = $c->server->jsonrpc->config->path;

            my $parser    = $c->req->jsonrpc->_jsonrpc_parser;
            my @requests  = map { $parser->encode($_); } @{$c->req->args};
            my @responses = ();

            foreach my $request (@requests) {
                $c->req->_body(HTTP::Body->new($c->req->content_type, length($request)));
                $c->req->_body->add($request);
                $c->server->jsonrpc->config->path('');
                $c->stash->{'jsonrpc_generated'} = 0;
                $c->res->body('');

                $c->prepare_action();
                $c->dispatch();
                unless ($c->stash->{'jsonrpc_generated'}) {
                    $c->stash->{'current_view_instance'}->process($c);
                }

                push(@responses, $c->res->body);
            }

            # Restore values.
            $c->req->_body($body);
            $c->server->jsonrpc->config->path($path);

            $c->res->body('[' . join(',', @responses) . ']');
        }
    );
    $class->next::method(@_);
}


1;
