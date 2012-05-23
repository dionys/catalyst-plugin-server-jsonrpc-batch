package Catalyst::Plugin::Server::JSONRPC::Batch;

use strict;
use warnings;

use Class::MOP ();
use HTTP::Body ();


our $VERSION = '0.01';

our $Method = 'system.handle_batch';


BEGIN {
    my $class = 'JSON::RPC::Common::Procedure::Call';

    Class::MOP::load_class($class) unless Class::MOP::is_class_loaded($class);

    my $meta = $class->meta;

    $meta->make_mutable();
    $meta->add_around_method_modifier(
        'inflate',
        sub {
            my ($meth, $class, @args) = @_;

            if (@args == 1 && ref($args[0]) eq 'ARRAY') {
                return $class->new_from_data(
                    jsonrpc => '2.0',
                    id      => scalar(time()),
                    method  => $Catalyst::Plugin::Server::JSONRPC::Batch::Method,
                    params  => $args[0]
                );
            }
            else {
                return $meth->($class, @args);
            }
        }
    );
    $meta->make_immutable();
}


sub setup_engine {
    my $app = shift();

    $app->server->jsonrpc->add_private_method(
        $Method => sub {
            my ($c, @args) = @_;

            my $config = $c->server->jsonrpc->config;
            my $req    = $c->req;
            my $res    = $c->res;
            my $stash  = $c->stash;
            my $parser = $req->jsonrpc->_jsonrpc_parser;
            my @results;

            # HACK: Store values.
            my $body = $req->_body;
            my $path = $config->path;

            foreach (map { $parser->encode($_) } @{$req->args}) {
                $config->path('');
                $stash->{jsonrpc_generated} = 0;
                $req->_body(HTTP::Body->new($req->content_type, length($_)));
                $req->_body->add($_);
                $res->body('');

                $c->prepare_action();
                $c->dispatch();
                $stash->{current_view_instance}->process($c)
                        unless $stash->{jsonrpc_generated};

                push(@results, $res->body);
            }

            # Restore values.
            $req->_body($body);
            $config->path($path);

            my $result = '[' . join(',', @results) . ']';

            $res->content_length(length($result));
            $res->body($result);
        }
    );

    $app->next::method(@_);
}


1;

__END__

=pod

=head1 NAME

Catalyst::Plugin::Server::JSONRPC::Batch - Batch calls implementation for
Catalyst JSONRPC-server plugin.

=head1 SYNOPSIS

    use Catalyst qw/
        Server
        Server::JSONRPC
        Server::JSONRPC::Batch
    /;

=head1 DESCRIPTION

=head1 INTERNAL METHODS

=over 4

=item setup_engine

=back

=head1 SEE ALSO

L<JSON-RPC 2.0 Specification|http://www.jsonrpc.org/specification>

=head1 AUTHORS

Denis Ibaev (dionys), C<dionys@gmail.com>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2011 the aforementioned authors. All rights reserved. This
program is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut
