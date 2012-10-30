package Ocean::HTTPBinding::StreamFactory::JSONRPC;

use strict;
use warnings;

use parent 'Ocean::StreamFactory';

use AnyEvent::Handle;

use Ocean::Stream;
use Ocean::StreamComponent::IO;
use Ocean::StreamComponent::IO::Decoder::JSON;
use Ocean::StreamComponent::IO::Decoder::JSON::JSONRPC;
use Ocean::StreamComponent::IO::Encoder::JSONRPC;
use Ocean::StreamComponent::IO::Socket::AEHandleAdapter;
use Ocean::Constants::ProtocolPhase;

sub create_stream {
    my ($self, $client_id, $client_socket) = @_;
    return Ocean::Stream->new(
        id => $client_id,
        io => Ocean::StreamComponent::IO->new(
            decoder  => Ocean::StreamComponent::IO::Decoder::JSON->new(
                protocol => Ocean::StreamComponent::IO::Decoder::JSON::JSONRPC->new, 
            ), 
            encoder  => Ocean::StreamComponent::IO::Encoder::JSONRPC->new,
            socket   => $client_socket,
        ),
        initial_protocol => Ocean::Constants::ProtocolPhase::AVAILABLE,
    );
}

1;
