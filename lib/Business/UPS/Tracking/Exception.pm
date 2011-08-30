# ============================================================================
package Business::UPS::Tracking::Exception;
# ============================================================================
use utf8;
use 5.0100;

use base qw(Moose::Error::Default);
use strict;
use warnings;

our $VERSION = $Business::UPS::Tracking::VERISON;

sub new {
    my ( $self, @args ) = @_;
    
    $self->create_error_exception(@args);
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

sub _inline_new {
    my ( $self, %params ) = @_;
 
    my $depth = ($params{depth} || 0) - 1;
    
    my $string = 'Business::UPS::Tracking::Exception::create_error_exception('
        .'depth       => ' . $depth. ', ';
    foreach (qw(message method method evaltext sub_name last_error sub is_require has_args line pack file)) {
        next
            unless defined $params{$_};
        $string .= "$_       => " . $params{$_}. ', ';
    }
    $string .= ')';
    
    return $string;
}


#sub _inline_new {
#    my ( $self, %args ) = @_;
# 
#    my $depth = ($args{depth} || 0) - 1;
#    return 'Moose::Error::Util::create_error('
#      . 'message => ' . $args{message} . ', '
#      . 'depth   => ' . $depth         . ', '
#  . ')';
#}
# 
#
#sub create_error_croak {
#    _create_error_carpmess(@_);
#}
#
#sub _create_error_carpmess {
#    my %args = @_;
#
#    my $carp_level = 3 + ( $args{depth} || 0 );
#    local $Carp::MaxArgNums = 20; # default is 8, usually we use named args which gets messier though
#
#    my @args = exists $args{message} ? $args{message} : ();
#
#    if ( $args{longmess} || $Carp::Verbose ) {
#        local $Carp::CarpLevel = ( $Carp::CarpLevel || 0 ) + $carp_level;
#        return Carp::longmess(@args);
#    } else {
#        return Carp::ret_summary($carp_level, @args);
#    }
#}

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

1;