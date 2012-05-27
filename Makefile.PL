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

resources 'bugtracker' => 'http://github.com/dionys/catalyst-plugin-server-jsonrpc-batch/issues';
resources 'license'    => 'http://dev.perl.org/licenses/';
resources 'repository' => 'http://github.com/dionys/catalyst-plugin-server-jsonrpc-batch';

no_index 't';
no_index 'inc';

auto_install;

WriteAll;
