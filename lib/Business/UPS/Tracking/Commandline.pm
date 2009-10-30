# ============================================================================
package Business::UPS::Tracking::Commandline;
# ============================================================================
use utf8;
use 5.0100;

use metaclass (
    metaclass   => "Moose::Meta::Class",
    error_class => "Business::UPS::Tracking::Exception",
);
use Moose;

extends qw(Business::UPS::Tracking::Request);
with qw(MooseX::Getopt);

our $VERSION = $Business::UPS::Tracking::VERISON;

use Path::Class::File;

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Commandline - Commandline interface to UPS tracking

=head1 SYNOPSIS

  my $commandline = Business::UPS::Tracking::Commandline->new_with_options;
  # Params are taken from @ARGV
  $commandline->execute; 

=head1 DESCRIPTION

This class allows Business::UPS::Tracking being called from a commandline
script using L<MooseX::Getopt>. (See L<ups_tracking>)

=head1 ACCESSORS

=head2 Inherited

All accessors from L<Business::UPS::Tracking::Request>

=head2 verbose

Be verbose

=head2 config

Path to the webservice configuration file. Defaults to C<~/.ups_tracking>

Example configuration file:

 <?xml version="1.0"?>
 <UPS_tracing_webservice_config>
    <AccessLicenseNumber>1CFFED5A5E91B17</AccessLicenseNumber>
    <UserId>myupsuser</UserId>
    <Password>secret</Password>
 </UPS_tracing_webservice_config>

=head2 tracking

L<Business::UPS::Tracking> object. If not supplied the object will be
built from data in C<config>

=head1 METHODS

=head3 execute

 $commandline->execute;

Performs a UPS webservice query/request.

=cut

has 'tracking' => (
    is       => 'rw',
    required => 0,
    isa      => 'Business::UPS::Tracking',
    traits   => [ 'NoGetopt' ],
    lazy_build     => 1,
);

has 'verbose' => (
    is       => 'rw',
    isa      => 'Bool',
    documentation   => 'Be verbose',
);

has 'config' => (
    is       => 'rw',
    isa      => 'Str',
    default  => sub {
        Path::Class::File->new( $ENV{HOME}, '.ups_tracking' )->stringify;
    },
    documentation => 'UPS tracking webservice access config file'
);

MooseX::Getopt::OptionTypeMap->add_option_type_to_map(
    'TrackingNumber' => '=s',
    'CountryCode'    => '=s',
);

__PACKAGE__->meta->make_immutable;

sub execute {
    my $self = shift;
    
    my $response = $self->run();
    
    my $count = 1;
    
    foreach my $shipment (@{$response->shipment}) {
        say ".============================================================================.";
        say "| Shipment $count                                                                 |";
        say $shipment->serialize->draw;
        say "";
        if ($self->verbose) {
            say $shipment->xml->toString(1);
        }
        $count ++;
        
    }
}

sub _build_tracking {
    my ($self) = @_;
    
    unless (-e $self->config) {
        Business::UPS::Tracking::X->throw('Could not find UPS tracking webservice access config file at "'.$self->config.'"');
    }
    
    my $parser = XML::LibXML->new();
    
    my $config = eval {
        my $document = $parser->parse_file( $self->config );
        my $root = $document->documentElement();
        
        my $params = {};
        foreach my $param ($root->childNodes) {
            $params->{$param->nodeName} = $param->textContent; 
        }
        return $params;
    };
    if (! $config) {
        Business::UPS::Tracking::X->throw('Could not open/parse UPS tracking webservice access config file at '.$self->config.' : '.$@);
    }
    
    return Business::UPS::Tracking->new(%$config);
}
1;