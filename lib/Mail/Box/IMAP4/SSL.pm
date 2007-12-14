package Mail::Box::IMAP4::SSL;
use 5.006;
use strict;
use warnings;

use base 'Mail::Box::IMAP4';
use IO::Socket::SSL qw();
use Mail::Reporter qw();
use Mail::Transport::IMAP4 qw();

our $VERSION = '0.03'; 

my $imaps_port = 993; # standard port for IMAP over SSL

#--------------------------------------------------------------------------#
# init
#--------------------------------------------------------------------------#

sub init {
    my ($self, $args) = @_;

    # until we're connected, mark as closed in case we exit early
    # (otherwise, Mail::Box::DESTROY will try to close/unlock, which dies)
    $self->{MB_is_closed}++;

    # if no port is provided, use the default
    $args->{server_port} ||= $imaps_port;

    # Mail::Box::IMAP4 wants a folder or it throws warnings
    $args->{folder} ||= '/';

    # Use messages classes from our superclass type
    $args->{message_type} ||= 'Mail::Box::IMAP4::Message';

    # giving us a transport argument is an error since our only purpose
    # is to create the right kind of transport object
    if ( $args->{transporter} ) {
        Mail::Reporter->log(ERROR => 
            "The 'transporter' option is not valid for " . __PACKAGE__
        );
        return;
    }

    # some arguments are required to connect to a server
    for my $req ( qw/ server_name username password/ ) {
        if ( not defined $args->{$req} ) {
            Mail::Reporter->log(ERROR =>  
                "The '$req' option is required for " . __PACKAGE__ 
            );
            return;
        }
    }

    # trying to create the transport object

    my $ssl_socket = IO::Socket::SSL->new(  
        Proto    => 'tcp',
        PeerAddr => $args->{server_name},
        PeerPort => $args->{server_port},   
    );
    
    unless ( $ssl_socket ) {
        Mail::Reporter->log(ERROR => 
            "Couldn't connect to '$args->{server_name}': " 
            . IO::Socket::SSL::errstr()
        );
        return;
    }

    my $imap = Mail::IMAPClient->new( 
        User     => $args->{username},
        Password => $args->{password},
        Socket   => $ssl_socket,
        Uid      => 1,              # Mail::Transport::IMAP4 does this
        Peek     => 1,              # Mail::Transport::IMAP4 does this
    );
    my $imap_err = $@;
        
    unless ( $imap && $imap->IsAuthenticated ) {
        Mail::Reporter->log( ERROR => 
            "Login rejected for user '$args->{username}'"
            . " on server '$args->{server_name}': $imap_err"
        );
        return;
    }

    $args->{transporter} = Mail::Transport::IMAP4->new(
        imap_client => $imap,
    );
        
    unless ( $args->{transporter} ) {
        Mail::Reporter->log( ERROR => 
            "Error creating Mail::Transport::IMAP4 from the SSL connection."
        );
        return;
    }
    
    # now that we have a valid transporter, mark ourselves open
    # and let the superclass initialize
    delete $self->{MB_is_closed};
    $self->SUPER::init($args); 

}

sub type {'imaps'}

1; #modules must return true

__END__

#--------------------------------------------------------------------------#
# pod documentation 
#--------------------------------------------------------------------------#

=begin wikidoc

= NAME

Mail::Box::IMAP4::SSL - handle IMAP4 folders with SSL

= VERSION

This documentation describes version %%VERSION%%.

= INHERITANCE

    Mail::Box::IMAP4::SSL
      is a Mail::Box::IMAP4
      is a Mail::Box::Net
      is a Mail::Box
      is a Mail::Reporter

= SYNOPSIS

    # standalone
    use Mail::Box::IMAP4::SSL;

    my $folder = new Mail::Box::IMAP4::SSL(
        username => 'johndoe',
        password => 'wbuaqbr',
        server_name => 'imap.example.com',
    );

    # with Mail::Box::Manager
    use Mail::Box::Manager;

    my $mbm = Mail::Box::Manager->new;
    $mbm->registerType( imaps => 'Mail::Box::IMAP4::SSL' );
    
    my $inbox = $mbm->open(
        folder => 'imaps://johndoe:wbuaqbr@imap.example.com/INBOX',
    );

= DESCRIPTION

This is a thin subclass of [Mail::Box::IMAP4] to provide IMAP over SSL (aka
IMAPS).  It hides the complexity of setting up Mail::Box::IMAP4 with
[IO::Socket::SSL], [Mail::IMAPClient] and [Mail::Transport::IMAP4].

In all other respects, it resembles [Mail::Box::IMAP4].  See that module
for documentation.

= METHODS


== {Mail::Box::IMAP4::SSL->new( %options )}

    my $folder = new Mail::Box::IMAP4::SSL(
        username => 'johndoe',
        password => 'wbuaqbr',
        server_name => 'imap.example.com',
        %other_options
    );

The {username}, {password} and {server_name} options arguments are required.
The {server_port} option is automatically set to the standard IMAPS port 993,
but can be changed if needed. See [Mail::Box::IMAP4] for additional options.

Note: It is an error to provide a {transporter} options, as this class exists
only to create an SSL-secured {transporter} for {Mail::Box::IMAP4}.

= BUGS

Please report any bugs or feature requests using the CPAN Request Tracker.  
Bugs can be submitted through the web interface at 
[http://rt.cpan.org/Dist/Display.html?Queue=Mail::Box::IMAP4::SSL]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

Please limit your bug/feature reports to SSL-specific issues.  All other
issues should be directed to the maintainer of {Mail::Box::IMAP4}.

= SEE ALSO

* [Mail::Box]
* [Mail::Box::IMAP4]

= AUTHOR

David A. Golden (DAGOLDEN)

= COPYRIGHT AND LICENSE

Copyright (c) 2007 by David A. Golden

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at 
[http://www.apache.org/licenses/LICENSE-2.0]

Files produced as output though the use of this software, shall not be
considered Derivative Works, but shall be considered the original work of the
Licensor.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end wikidoc

=cut
