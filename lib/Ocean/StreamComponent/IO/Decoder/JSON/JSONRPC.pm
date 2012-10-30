package Ocean::StreamComponent::IO::Decoder::JSON::JSONRPC;

use strict;
use warnings;

use Data::Dumper;

use HTTP::Parser::XS qw(parse_http_request);
use Log::Minimal;

use Ocean::Constants::JSONRPC;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::Util::HTTPBinding;

use Try::Tiny;

use constant {
    STATE_INIT        => 0,
    STATE_HANDSHAKED  => 1,
};

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _buffer          => '', 
        _state           => STATE_INIT,
        _on_handshake    => sub {},
        _on_read_frame   => sub {},
#       _max_buffer_size => $args{max_buffer_size} || 1024 * 10,
    }, $class;
    return $self;
}

sub on_handshake {
    my ($self, $callback) = @_;
    $self->{_on_handshake} = $callback;
}

sub on_read_frame {
    my ($self, $callback) = @_;
    $self->{_on_read_frame} = $callback;
}

sub reset {
    my $self = shift;
    $self->{_state}  = STATE_INIT;
    $self->{_buffer} = '';
}

sub release {
    my $self = shift;
    delete $self->{_on_handshake}
        if $self->{_on_handshake};
    delete $self->{_on_read_frame}
        if $self->{_on_read_frame};
}

sub parse_more {
    my ($self, $data) = @_;
    $self->{_buffer} .= $data;
    $self->_parse();
}

sub _parse {
    my $self = shift;

    my $pos = index($self->{_buffer}, "\r\n\r\n");
    if ($pos >= 0) {
        my $buffer = $self->{_buffer};
        my $header = substr($self->{_buffer}, 0, $pos + 4);
        my $body = substr($self->{_buffer}, $pos + 4);

        my $env = {};
        my $ret = parse_http_request($header, $env);
        if ($ret == -2) { # incomplete request, return and wait for the remaining buffer
            debugf("<Stream> <Decoder> Request incomplete for: '%s'", $header);
            Ocean::Error::JSONRPCError::ParseError->throw();
            return;
        }
        elsif ($ret == -1) {
            $self->reset();
            debugf("<Stream> <Decoder> Failed to parse header: '%s'", $header);
            Ocean::Error::JSONRPCError::ParseError->throw();
            return;
        }

        debugf("<Stream> <Decoder> parsed header successfully");

        if ( $env->{REQUEST_METHOD} ne 'POST') {
            $self->reset();
            debugf("<Stream> <Decoder> invalid request method: '%s'", $header);
            Ocean::Error::JSONRPCError::InvalidRequest->throw();
            return;
        }

        if( defined($env->{CONTENT_LENGTH}) and $env->{CONTENT_LENGTH} > length($body) ) {
            debugf('<Stream> <Decoder> missing content (expected %d; got %d)', $env->{CONTENT_LENGTH}, length($body));
            Ocean::Error::JSONRPCError::InvalidRequest->throw();
            return;
        }

        debugf('<Stream> <Decoder> got body: %s', $body);

        my %header_params = ();

        my $op = Ocean::Constants::JSONRPC::RPC_CALL;

        try {
            $self->{_on_read_frame}->($op, $body);
        } catch {
            if (!ref($_)) {
                # no reference, an error occured somewhere
                Ocean::Error::JSONRPCError::ServerError->throw(
                    message => 'Server error: ' . $_,
                );
                return;
            } elsif ($_->type eq Ocean::Constants::StreamErrorType::INVALID_JSON) {
                Ocean::Error::JSONRPCError::ParseError->throw();
                return;
            } elsif ($_->isa('Ocean::Error::JSONRPCError')) {
                die $_;
                return;
            } else {
                Ocean::Error::JSONRPCError::ServerError->throw(
                    message => 'Server error: ' . $_->as_string,
                );
                return;
            }
        };

        return;

    }
}

1;
