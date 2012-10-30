package Ocean::JSON::JSONRPCClassifier;

use strict;
use warnings;

use Ocean::Constants::EventType;

sub classify {
    my ($self, $obj) = @_;
    return unless ($obj->{jsonrpc} && $obj->{method});

    if ($obj->{method} eq 'user_event') {
        return Ocean::Constants::EventType::PUBLISH_EVENT;
    }
    return;
}

1;
