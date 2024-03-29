# -*- mode: perl; c-basic-offset: 4; indent-tabs-mode: nil; -*-

use 5.006; #weaken
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

# I should maybe use something like Shipwright...
regen_README('bin/scrape.pl');
#regen_EXAMPLES();

WriteMakefile1(
    MIN_PERL_VERSION => '5.006',
    META_MERGE => {
        resources => {
            repository => 'http://github.com/Corion/app-scrape',
        },
    },
    #BUILD_REQUIRES => {
    #                    'Task::Weaken' => 0, #to be sure that weaken is present
    #},
    'NAME'          => 'App::scrape',
    'LICENSE'       => 'perl',
    'VERSION_FROM'  => 'lib/App/scrape.pm', # finds $VERSION
    'EXE_FILES'     => ['bin/scrape.pl', 'bin/scrape2rss.pl'],
    'PREREQ_PM'     => { 
                        # the first DOM we implement
                        'HTML::TreeBuilder::XPath' => 0.10, # v0.10 for ->findvalues()
                        'HTML::Selector::XPath' => 0,
                        'URI' => 0,
                        'XML::Atom::SimpleFeed' => 0, # for scrape2rss
                        'LWP::Simple' => 0, # for page fetching
                        'Time::Piece' => 0, # for date parsing
                        'Exporter' => 0,
                        'Getopt::Long' => 0,
                        'Pod::Usage' => 0,
                      }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM   => 'lib/App/scrape.pm', # retrieve abstract from module
    AUTHOR          => 'Max Maischein <corion@cpan.org>',
);

1;

sub WriteMakefile1 {  #Written by Alexandr Ciornii, version 0.21. Added by eumm-upgrade.
    my %params=@_;
    my $eumm_version=$ExtUtils::MakeMaker::VERSION;
    $eumm_version=eval $eumm_version;
    die "EXTRA_META is deprecated" if exists $params{EXTRA_META};
    die "License not specified" if not exists $params{LICENSE};
    if ($params{BUILD_REQUIRES} and $eumm_version < 6.5503) {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM}={ %{$params{PREREQ_PM} || {}} , %{$params{BUILD_REQUIRES}} };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES} if $eumm_version < 6.52;
    delete $params{MIN_PERL_VERSION} if $eumm_version < 6.48;
    delete $params{META_MERGE} if $eumm_version < 6.46;
    delete $params{META_ADD} if $eumm_version < 6.46;
    delete $params{LICENSE} if $eumm_version < 6.31;
    delete $params{AUTHOR} if $] < 5.005;
    delete $params{ABSTRACT_FROM} if $] < 5.005;
    delete $params{BINARY_LOCATION} if $] < 5.005;
    
    WriteMakefile(%params);
}

sub regen_README {
    eval {
        require Pod::Readme;

        my $parser = Pod::Readme->new();

        # Read POD from Module.pm and write to README
        $parser->parse_from_file($_[0], 'README');
    };
    eval {
        require Pod::Markdown;

        my $parser = Pod::Markdown->new();

        # Read POD from Module.pm and write to README
        $parser->parse_from_file($_[0]);
        open my $fh, '>', 'README.mkdn'
            or die "Couldn't open 'README.mkdn': $!";
        print $fh $parser->as_markdown;
    };
}


sub regen_EXAMPLES {
    my $perl = $^X;
    warn "(Re)Creating lib/App/scrape/Examples.pm\n";
    if ($perl =~/\s/) {
        $perl = qq{"$perl"};
    };
    my $examples = `$perl -w examples/gen_examples_pod.pl`;
    if ($examples) {
        $examples =~ s/\r\n/\n/g;
        if (open my $out, '>', 'lib/App/scrape/Examples.pm') {
            binmode $out;
            print $out $examples;
        };
    };
};