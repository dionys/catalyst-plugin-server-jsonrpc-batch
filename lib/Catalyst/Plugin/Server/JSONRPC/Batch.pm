package Catalyst::Plugin::Server::JSONRPC::Batch;

use strict;
use warnings;

use Class::MOP ();


our $VERSION = '0.01';

our $Method = 'system.handle_batch';

BEGIN {
    my $mod = 'JSON::RPC::Common::Procedure::Call';

    Class::MOP::load_class($mod) unless Class::MOP::is_class_loaded($mod);

    my $meta = $mod->meta;

    $meta->make_mutable();
    $meta->add_around_method_modifier(
        'inflate',
        sub {
            my ($meth, $mod, @args) = @_;

            if (@args == 1 && ref($args[0]) eq 'ARRAY') {
                return $mod->new_from_data(
                    'jsonrpc' => '2.0',
                    'id'      => scalar(time()),
                    'method'  => $Catalyst::Plugin::Server::JSONRPC::Batch::Method,
                    'params'  => $args[0]
                );
            }
            else {
                return $meth->($mod, @args);
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

            my $conf = $c->server->jsonrpc->config;
            my $req  = $c->req;
            my $res  = $c->res;
            my $stor = $c->stash;
            my $par  = $req->jsonrpc->_jsonrpc_parser;
            my @rets = ();

            # HACK: Store values.
            my $body = $req->_body;
            my $path = $conf->path;

            foreach (map { $par->encode($_) } @{$req->args}) {
                $conf->path('');
                $stor->{'jsonrpc_generated'} = 0;
                $req->_body(HTTP::Body->new($c->req->content_type, length($_)));
                $req->_body->add($_);
                $res->body('');

                $c->prepare_action();
                $c->dispatch();
                $stor->{'current_view_instance'}->process($c)
                        unless $stor->{'jsonrpc_generated'};

                push(@rets, $res->body);
            }

            # Restore values.
            $req->_body($body);
            $conf->path($path);

            my $result = '[' . join(',', @rets) . ']';
            $res->content_length(length $result);
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
