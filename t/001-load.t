use strict;

use Test::More tests => 1;


BEGIN {
    use_ok('Catalyst::Plugin::Server::JSONRPC::Batch')
            or print("Bail out!\n");
}

diag(sprintf(
    "Testing Catalyst::Plugin::Server::JSONRPC::Batch %s, Perl %s, %s",
    $Catalyst::Plugin::Server::JSONRPC::Batch::VERSION, $], $^X
));
