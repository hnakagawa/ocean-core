package Ocean::Error;

use strict;
use warnings;

use Ocean::Constants::JSONRPC;

use overload  
    q{""}    => sub { $_[0]->as_string },
    fallback => 1;

sub throw {
    my ($class, %args) = @_;
    die $class->new(%args);
}

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        message => 'error', 
        type    => '',
        %args
    }, $class;
    return $self;
}

sub message   { $_[0]->{message} }
sub type      { $_[0]->{type}    }
sub as_string { sprintf(q{%s: %s}, $_[0]->type, $_[0]->message) };

package Ocean::Error::InvalidRouteSetting;
our @ISA = qw(Ocean::Error);
sub type { 'invalid route setting' }

package Ocean::Error::InitializationFailed;
our @ISA = qw(Ocean::Error);
sub type { 'initialization failed' }

package Ocean::Error::NotInitialized;
our @ISA = qw(Ocean::Error);

package Ocean::Error::FileNotFound;
our @ISA = qw(Ocean::Error);

package Ocean::Error::AbstractMethod;
our @ISA = qw(Ocean::Error);
sub type { 'abstract method' }

package Ocean::Error::NotImplemented;
our @ISA = qw(Ocean::Error);
sub type { 'method not implemented' }

package Ocean::Error::ParamNotFound;
our @ISA = qw(Ocean::Error);

package Ocean::Error::ProtocolError;
our @ISA = qw(Ocean::Error);

package Ocean::Error::HTTPHandshakeError;
our @ISA = qw(Ocean::Error);
sub code { $_[0]->{code} || '' }

package Ocean::Error::MessageError;
our @ISA = qw(Ocean::Error);
sub condition { $_[0]->{condition} || '' }

package Ocean::Error::IQError;
our @ISA = qw(Ocean::Error);
sub id        { $_[0]->{id}        || '' }
sub condition { $_[0]->{condition} || '' }

package Ocean::Error::SASLFailure;
our @ISA = qw(Ocean::Error);

package Ocean::Error::ConditionMismatchedServerEvent;
our @ISA = qw(Ocean::Error);

package Ocean::Error::JSONRPCError;
our @ISA = qw(Ocean::Error);

package Ocean::Error::JSONRPCError::ParseError;
our @ISA = qw(Ocean::Error::JSONRPCError);
sub type    { Ocean::Constants::JSONRPC::PARSE_ERROR }
sub message { 'Parse error' }

package Ocean::Error::JSONRPCError::InvalidRequest;
our @ISA = qw(Ocean::Error::JSONRPCError);
sub type    { Ocean::Constants::JSONRPC::INVALID_REQUEST }
sub message { 'Invalid Request' }

package Ocean::Error::JSONRPCError::MethodNotFound;
our @ISA = qw(Ocean::Error::JSONRPCError);
sub type    { Ocean::Constants::JSONRPC::METHOD_NOT_FOUND }
sub message { 'Method not found' }

package Ocean::Error::JSONRPCError::InvalidParams;
our @ISA = qw(Ocean::Error::JSONRPCError);
sub type    { Ocean::Constants::JSONRPC::INVALID_PARAMS }
sub message { 'Invalid params' }

package Ocean::Error::JSONRPCError::InternalError;
our @ISA = qw(Ocean::Error::JSONRPCError);
sub type    { Ocean::Constants::JSONRPC::INTERNAL_ERROR }
sub message { 'Internal error' }

package Ocean::Error::JSONRPCError::ServerError;
our @ISA = qw(Ocean::Error::JSONRPCError);


1;

