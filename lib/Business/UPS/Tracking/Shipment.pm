# ================================================================
package Business::UPS::Tracking::Shipment;
# ================================================================
use utf8;
use Moose;
use 5.0100;

use Business::UPS::Tracking::Utils;

has 'xml' => (
    is      => 'ro',
    required=> 1,
    isa     => 'XML::LibXML::Node',
);
has 'ScheduledDelivery' => (
    is      => 'ro',
    isa     => 'Date',
    lazy    => 1,
    builder => '_build_ScheduledDelivery',
);
has 'PickupDate' => (
    is      => 'ro',
    isa     => 'Date',
    lazy    => 1,
    builder => '_build_PickupDate',
);
has 'ShipperNumber' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_ShipperNumber',
);
has 'ShipperAddress' => (
    is      => 'ro',
    isa     => 'Business::UPS::Tracking::Element::Address',
    lazy    => 1,
    builder => '_build_ShipperAddress',
);
has 'ShipmentWeight' => (
    is      => 'ro',
    isa     => 'Business::UPS::Tracking::Element::Weight',
    lazy    => 1,
    builder => '_build_ShipmentWeight',
);
has 'ShipToAddress' => (
    is      => 'ro',
    isa     => 'Business::UPS::Tracking::Element::Address',
    lazy    => 1,
    builder => '_build_ShipToAddress',
);
has 'ServiceCode' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_ServiceCode',
);
has 'ServiceDescription' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_ServiceDescription',
);
has 'ShipmentReferenceNumber' => (
    is      => 'ro',
    isa     => 'Business::UPS::Tracking::Element::ReferenceNumber',
    lazy    => 1,
    builder => '_build_ShipmentReferenceNumber',
);



sub _build_ScheduledDelivery {
    my ($self) = @_;

    my $datestr = $self->xml->findvalue('ScheduledDeliveryDate');
    my $date    = Business::UPS::Tracking::Utils::parse_date($datestr);

    my $timestr = $self->xml->findvalue('ScheduledDeliveryTime');
    $date = Business::UPS::Tracking::Utils::parseTime( $timestr, $date );

    return $date;
}

sub _build_PickupDate {
    my ($self) = @_;

    my $datestr = $self->xml->findvalue('PickupDate');
    return Business::UPS::Tracking::Utils::parse_date($datestr);
}

sub _build_ShipperNumber {
    my ($self) = @_;
    
    return $self->xml->findvalue('Shipper/ShipperNumber');
}

sub _build_ShipperAddress {
    my ($self) = @_;
    
    return Business::UPS::Tracking::Utils::build_address($self->xml,'Shipper/Address');
}

sub _build_ShipmentWeight {
    my ($self) = @_;
    
    my $node = $self->xml->findnodes('ShipmentWeight')->get_node(1);
    return
        unless $node;
    return Business::UPS::Tracking::Element::Weight->new(
        xml => $node
    );
}

sub _build_ShipToAddress {
    my ($self) = @_;
    
    return Business::UPS::Tracking::Utils::build_address($self->xml,'ShipTo/Address');
}


sub _build_ServiceCode {
    my ($self) = @_;
    
    return $self->xml->findvalue('Service/Code');
}

sub _build_ServiceDescription {
    my ($self) = @_;
    
    return $self->xml->findvalue('Service/Description');
}


sub _build_ShipmentReferenceNumber {
    my ($self) = @_;
    
    return Business::UPS::Tracking::Utils::build_referencenumber($self->xml,'ReferenceNumber');
}



__PACKAGE__->meta->make_immutable;

1;