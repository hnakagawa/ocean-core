package Ocean::Stanza::Incoming::PubSubEvent;

use strict;
use warnings;

use constant {
    TO      => 0,
    FROM    => 1,
    NODE    => 2,
    ITEMS   => 3,
    REQ_ID  => 4,
};

sub new {
    my ($class, $to, $from, $node, $items, $req_id) = @_;
    my $self = bless [$to, $from, $node, $items, $req_id], $class;
    return $self;
}

sub to     { $_[0]->[TO]     }
sub from   { $_[0]->[FROM]   }
sub node   { $_[0]->[NODE]   }
sub items  { $_[0]->[ITEMS]  }
sub req_id { $_[0]->[REQ_ID] }

1;
