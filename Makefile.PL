# Load the Module::Install bundled in ./inc/
use strict;
use inc::Module::Install;

# Define metadata
name            'Business-UPS-Tracking';
all_from        'lib/Business/UPS/Tracking.pm';

perl_version    '5.010';



# Specific dependencies
requires        'overload'              => 0;
requires        'Moose'                 => 0;
requires        'DateTime'              => '0.44';
requires        'Exception::Class'      => 0;
requires        'LWP::UserAgent'        => 0;
unless (can_use('IO::Socket::SSL')) {
    requires    'Crypt::SSLeay'         => 0;
}
requires        'XML::LibXML'           => 0;

build_requires  'Test::NoWarnings'      => 0;

repository 'git://github.com/maros/Business-UPS-Tracking.git';

WriteAll;

sub check_modules {
    my @modules = @_;
    
    foreach my $module (@modules) {
        eval qq[use $module];
        if ($@) {
            next;
        }
        return 0;
    }
    return 1;
}