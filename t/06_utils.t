#!perl

use strict;
use warnings;

use Test::NoWarnings;
use Test::More tests => 1;

use lib qw(t/);
use testlib;

use DateTime;
use Business::UPS::Tracking::Utils;

my $d  = DateTime->new( year => 2018, month => 6, day => 27 );
my $dt = Business::UPS::Tracking::Utils::parse_time( "123000", $d);
is( $dt->strftime("%Y-%m-%d %H:%M:%S"), "2018-06-27 12:30:00" );

