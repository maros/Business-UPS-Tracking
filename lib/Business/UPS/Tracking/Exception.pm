# ============================================================================
package Business::UPS::Tracking::Exception;
# ============================================================================
use utf8;
use 5.0100;

use strict;
use warnings;
use parent qw(Moose::Error::Default);

our $VERSION = $Business::UPS::Tracking::VERSION;

use Exception::Class( 
    'Business::UPS::Tracking::X'    => {
        description   => 'Basic error'
    },
    'Business::UPS::Tracking::X::HTTP' => {
        isa           => 'Business::UPS::Tracking::X',    
        description   => 'HTTP error',
        fields        => [qw(http_response request)]
    },
    'Business::UPS::Tracking::X::UPS'  => {
        isa           => 'Business::UPS::Tracking::X',    
        description   => 'UPS error',
        fields        => [qw(code severity request context)]
    },
    'Business::UPS::Tracking::X::XML'  => {
        isa           => 'Business::UPS::Tracking::X',    
        description   => 'Malformed response xml',
        fields        => [qw(xml)]
    },
    'Business::UPS::Tracking::X::CLASS'  => {
        isa           => 'Business::UPS::Tracking::X',    
        description   => 'Class error',
        fields        => [qw(method depth evaltext sub_name last_error sub is_require has_args)],
    },
);

sub new {
    my ( $self, @args ) = @_;
    
    return $self->create_error_exception(@args)->throw;
}

sub create_error_exception {
    my ( $self, %params ) = @_;
    
    my $exception = Business::UPS::Tracking::X::CLASS->new( 
        error       => $params{message},
        method      => $params{method},
        depth       => $params{depth},
        evaltext    => $params{evaltext},
        sub_name    => $params{sub_name},
        last_error  => $params{last_error},
        sub         => $params{sub},
        is_require  => $params{is_require},
        has_args    => $params{has_args},
    );
    $exception->{line} = $params{line};
    $exception->{package} = $params{pack};
    $exception->{file} = $params{file};
    
    return $exception;
}



1;
