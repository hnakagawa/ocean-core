package Ocean::JSON::StanzaParser::PubSubEvent;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';
use Ocean::Error;
use Ocean::JID;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Stanza::Incoming::PubSubEvent;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{params};

    my $params_obj = $obj->{params};

    my $to = $params_obj->{to};
    my $to_jid = Ocean::JID->new($to);

    Ocean::Error::MessageError->throw(
        type      => Ocean::Constants::StanzaErrorType::CANCEL,
        condition => Ocean::Constants::StanzaErrorCondition::JID_MALFORMED,
        message   => sprintf(q{invalid jid, "%s"}, $to)
    ) unless $to_jid;

    my $from    = $params_obj->{from};
    my $node    = $params_obj->{node};
    my $items   = $params_obj->{items};
    my $req_id  = $obj->{id} || undef;

    my $pubsub_event = 
        Ocean::Stanza::Incoming::PubSubEvent->new($to_jid, $from, $node, $items, $req_id);
    return $pubsub_event;
}

1;
