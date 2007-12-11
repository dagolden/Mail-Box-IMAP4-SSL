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
        'Mail::Box' => 2.079,
        'Mail::IMAPClient' => 3.02,
    },
    build_requires  => {
        'Test::Exception'       => 0.25,
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
