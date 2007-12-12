package main;
use strict;
use warnings;

#--------------------------------------------------------------------------#
# requirements, fixtures and plan
#--------------------------------------------------------------------------#

use Test::More;
use Proc::Background;
use File::Spec;
use IO::CaptureOutput qw/capture/;
use Probe::Perl;


# expected credentials for server and client
my $username = 'johndoe';
my $password = '123456';
my $port = '31415';

# fire up the local mock server or skip tests
my $imapd = Proc::Background->new(
    { die_upon_destroy => 1 },
    Probe::Perl->find_perl_interpreter(),
    File::Spec->rel2abs(File::Spec->catfile(qw/t bin imapd.pl/)), 
    $port,
    $username, 
    $password,
);

sleep 2; # give time for imapd to fire up and listen

unless ( $imapd && $imapd->alive ) {
    plan skip_all => "Couldn't launch mock imapd on localhost"
}

plan tests =>  4 ;

my ($stdout, $stderr);

#--------------------------------------------------------------------------#
# tests begin here
#--------------------------------------------------------------------------#

require_ok( 'Mail::Box::IMAP4::SSL' );

ok( $imapd->alive, "mock imapd server is alive" );

my $imap;

capture sub {
    $imap = Mail::Box::IMAP4::SSL->new(
        username => $username,
        password => $password,
        server_name => '127.0.0.1',
        server_port => $port,
    );
} => \$stdout, \$stderr;

ok( $imap, "connected to mock imapd" );
is( $stderr, q{}, "No warnings during connection" );

