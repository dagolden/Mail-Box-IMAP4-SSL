#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Mail::Box::IMAP4::SSL;

my ($username,$password, $server);
{
    local $|; $|++;
    print "username: "; chomp($username = <>);
    print "password: "; chomp($password = <>);
    print "server  : "; chomp($password = <>);
}
    
my $imaps = Mail::Box::IMAP4::SSL->new(
    username => $username,
    password => $password,
    server_name => $server,
);

print "$_\n" for $imaps->listSubFolders;

