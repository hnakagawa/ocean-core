package Ocean::StreamComponent::IO::Encoder::JSONRPC;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Encoder::JSON';

use HTTP::Date;
use Log::Minimal;
use bytes ();
use Ocean::Constants::JSONRPC;
use Ocean::Constants::StreamErrorType;

sub _build_http_header {
    my ($self, %params) = @_;
    my @lines = (
        sprintf("HTTP/1.1 %d %s", $params{code}, $params{type}), 
        sprintf(q{Date: %s}, HTTP::Date::time2str(time())),
        "Content-Type: application/json",
        "Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
        "Pragma: no-cache",
        "Expires: -1",
        sprintf("Content-Length: %d", $params{length}),
        #"Connection: keep-alive",
    );
    my $header = join("\r\n", @lines);
    $header .= "\r\n\r\n";
    return $header;
}

sub send_packet {
    my ($self, $packet, $args) = @_;

    my $json = $self->_encode_json($packet) if $packet;

    # bytes::byte is deprecated?
    my $header = $self->_build_http_header(
        code   => $args->{code},
        type   => $args->{type},
        length => bytes::length($json) || 0,
    );

    $self->_write($header);
    $self->_write($json);
}


=pod

{ jsonrpc: '2.0',
  error: {
    code: integer,
    message: string,
  }
}

=cut

sub send_stream_error {
    my ($self, $type, $msg) = @_;

    if (   $type 
        && $type eq Ocean::Constants::StreamErrorType::CONNECTION_TIMEOUT 
        && $self->{_in_stream}) {

        my $obj = {
            jsonrpc => '2.0',
            error => {
                code => -32000,
                message => 'Timeout',
            },
        };

        my $status = {
            code => 500,
            type => "Internal Server Error",
        };


        $self->send_packet($obj, $status);
    } else {
        my $obj = {
            jsonrpc => '2.0',
            error => {
                code => $type,
                message => $msg,
            },
        };

        my $status = {
            code => 500,
            type => "Internal Server Error",
        };

        if ($type eq Ocean::Constants::JSONRPC::INVALID_REQUEST) {
            $status->{code} = 400;
            $status->{type} = 'Bad Request';
        } elsif ($type eq Ocean::Constants::JSONRPC::METHOD_NOT_FOUND) {
            $status->{code} = 404;
            $status->{type} = 'Not Found';
        }

        $self->send_packet($obj, $status);
    }
}

sub send_delivered_pubsub_response {
    my ($self, $event) = @_;

    my $status = {
        code => 200,
        type => 'OK',
    };

    if ($event->req_id) {
        my $obj = {
            jsonrpc => '2.0',
            result => 'ok',
            id => $event->req_id,
        };

        $self->send_packet($obj, $status);
    } else {
        $self->send_packet(undef, $status);
    }
}

1;
