use inc::Module::Install;

name     'Catalyst-Plugin-Server-JSONRPC-Batch';
all_from 'lib/Catalyst/Plugin/Server/JSONRPC/Batch.pm';
author   'Denis Ibaev <dionys@cpan.org>';
license  'perl';

requires       'Catalyst::Plugin::Server::JSONRPC';
requires       'Class::Load';
requires       'HTTP::Body';
requires       'JSON::RPC::Common';
build_requires 'Test::More';

no_index 't';

auto_install;

WriteAll;
