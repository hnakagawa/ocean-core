package Ocean::ServerComponentFactory::HTTPBinding::JSONRPC;

use strict;
use warnings;

use parent 'Ocean::ServerComponentFactory';

use Ocean::HTTPBinding::StreamFactory::JSONRPC;
use Ocean::HTTPBinding::StreamManager;

sub create_stream_manager {
    my ($self, $config) = @_;
    return Ocean::HTTPBinding::StreamManager->new(
        close_on_deliver => 1, 
    );
}

sub create_stream_factory {
    my ($self, $config) = @_;
    return Ocean::HTTPBinding::StreamFactory::JSONRPC->new;
}

1;
