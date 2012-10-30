package Ocean::Constants::JSONRPC;

use strict;
use warnings;

use constant {
    RPC_CALL =>  1001,

    # error codes
    PARSE_ERROR      => -32700,
    INVALID_REQUEST  => -32600,
    METHOD_NOT_FOUND => -32601,
    INVALID_PARAMS   => -32602,
    INTERNAL_ERROR   => -32603,
};

1;

