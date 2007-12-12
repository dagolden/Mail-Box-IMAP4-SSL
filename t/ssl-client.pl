#!/usr/bin/env perl
use strict;
use warnings;
use XDG;
use IO::Socket::SSL;

my $server_port = 31415;

my $server = IO::Socket::SSL->new(
    PeerAddr => 'localhost',
    PeerPort => $server_port,
    Proto => 'tcp',
    Timeout => 15,
) or die "Couldn't connect\n";

say "Connected to localhost, port $server_port";

while ( my $line = <> ) {
    print {$server} $line;
    chomp( my $response = <$server> );
    say "Server said: $response";
}

say "Client finished";

close($server);

