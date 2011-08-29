use 5.006;
use strict;
use warnings;

use Module::Build;


my $builder = Module::Build->new(
    'module_name'         => 'Catalyst::Plugin::Server::JSONRPC::Batch',
    'license'             => 'perl',
    'dist_author'         => q[Denis Ibaev <dionys@gmail.com>],
    'dist_version_from'   => 'lib/Catalyst/Plugin/Server/JSONRPC/Batch.pm',
    'build_requires'      => {
        'Test::More'                        => 0,
    },
    'requires'            => {
        'perl'                              => 5.006,
        'Catalyst::Plugin::Server::JSONRPC' => 0,
    },
    'add_to_cleanup'      => ['Catalyst-Plugin-Server-JSONRPC-Batch-*'],
    'create_makefile_pl'  => 'traditional',
);

$builder->create_build_script();
