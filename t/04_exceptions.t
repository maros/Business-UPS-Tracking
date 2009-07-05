#!perl

use Test::NoWarnings;
use Test::More tests => 4 + 1;

use lib qw(t/);
use testlib;


eval {
    my $request = Business::UPS::Tracking::Request->new( 
        TrackingNumber    => '1Z12345E029198079',
        tracking          => &tracking,
    );    
    return $request->run; 
};

if (my $e = Business::UPS::Tracking::X::UPS->caught) {
    pass('We have a Business::UPS::Tracking::X::UPS exeption');
    is($e->code,'151018','Exception code is ok');
} else {
    fail(ref $e);
    fail('Did not get a Business::UPS::Tracking::X::UPS exception');
    fail('Cannot check exception');
}
    
eval {
    my $tracking = &tracking;
    $tracking->url('https://really-broken-url-and-simulate-http-exception.com');
    my $request = Business::UPS::Tracking::Request->new( 
        TrackingNumber    => '1Z12345E029198079',
        tracking          => $tracking,
    );    
    return $request->run; 
};

if (my $e = Business::UPS::Tracking::X::HTTP->caught) {
    pass('We have a Business::UPS::Tracking::X::HTTP exeption');
    like($e->http_response->as_string ,qr/^500\s/,'HTTP response is ok');
} else {
    fail('Did not get a Business::UPS::Tracking::X::HTTP exception');
    fail('Cannot check exception');
}