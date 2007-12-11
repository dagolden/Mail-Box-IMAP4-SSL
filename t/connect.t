package main;
use strict;
use warnings;

#--------------------------------------------------------------------------#
# requirements, fixtures and plan
#--------------------------------------------------------------------------#

use Test::More;

my $username = $ENV{PERL_GMAIL_BOX_TEST};
my ($password, $server);

if ( $username ) {
    print STDERR "\n\nEnter password for $username:\n";
    chomp( $password = <> );
}

if ( ! ($username && $password ) ) {
    plan skip_all => 'Test email/password not provided. (See documentation.)';
}
else {
    plan tests =>  2 ;
}

my ($gmail, $err);

#--------------------------------------------------------------------------#
# tests begin here
#--------------------------------------------------------------------------#

require_ok( 'GMail::Box' );

SKIP: {
    eval {
        $gmail = GMail::Box->new(
            username => $username,
            password => $password,
        );
    };

    $err = $@;

    if ( $err =~ m{^Invalid user/password} ) {
        skip "Invalid username or password provided", 1;
    }
    else {
        isa_ok( $gmail, "GMail::Box" );
    }
}

