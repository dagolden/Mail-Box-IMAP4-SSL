use 5.006;
use strict;
use lib 'inc';
eval "require Pod::WikiDoc";
my $class = $@ ? "Module::Build" : "Module::Build::WikiDoc";
eval "require $class";
$class->new( 
    module_name         => 'Mail::Box::IMAP4::SSL',
    dist_author         => 'David A. Golden <dagolden@cpan.org>',
    license             => 'apache',
    create_readme       => 1,
    create_makefile_pl  => 'traditional',
    requires        => {
        'perl' => 5.006,
        'IO::Socket::SSL' => 1.12,
        'Mail::Box::IMAP4' => 2.079,
        'Mail::IMAPClient' => 3.02,
        'Mail::Transport::IMAP4' => 2.079,
    },
    build_requires  => {
        'File::Spec'            => 0.86, # perl 5.6.2
        'IO::CaptureOutput'     => 1.06,
        'Probe::Perl'           => 0.01,
        'Proc::Background'      => 1.08,
        'Test::More'            => 0.74, # various features/fixes
    },
    meta_merge            => { 
        no_index => { 
            directory => [ qw{
                examples
                inc
            }],
        },
        resources => {
            repository => 'http://dagolden.googlecode.com/svn/'
        },
    },
)->create_build_script;
