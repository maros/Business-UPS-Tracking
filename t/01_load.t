#!perl -T

use Test::More tests => 11;

use_ok( 'Business::UPS::Tracking' );
use_ok( 'Business::UPS::Tracking::Utils' );
use_ok( 'Business::UPS::Tracking::Response' );
use_ok( 'Business::UPS::Tracking::Request' );
use_ok( 'Business::UPS::Tracking::Shipment' );
use_ok( 'Business::UPS::Tracking::Shipment::Freight' );
use_ok( 'Business::UPS::Tracking::Shipment::SmallPackage' );
use_ok( 'Business::UPS::Tracking::Element::Activity' );
use_ok( 'Business::UPS::Tracking::Element::Address' );
use_ok( 'Business::UPS::Tracking::Element::Weight' );
use_ok( 'Business::UPS::Tracking::Element::ReferenceNumber' );
