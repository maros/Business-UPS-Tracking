# ================================================================
package Business::UPS::Tracking::Shipment;
# ================================================================
use utf8;
use Moose;
use 5.0100;

use Business::UPS::Tracking::Utils;

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Shipment - Base class for shipments

=head1 DESCRIPTION

This class is a base class for 
L<Business::UPS::Tracking::Shipment::SmallPackage> and 
L<Business::UPS::Tracking::Shipment::Freight>. Usually it is created 
automatically from a L<Business::UPS::Tracking::Response> object. It provides
accessors common to all shipment types.

=head1 ACCESSORS

=head2 xml

L<XML::LibXML::Node> node of the shipment.

=head2 ScheduledDelivery

Scheduled delivery date and time. Returns a L<DateTime> object.

=head2 PickupDate

Pickup date. Returns a L<DateTime> object.

=head2 ShipperNumber

Shipper UPS customer number.

=head2 ShipperAddress

Shipper address. Returns a L<Business::UPS::Tracking::Element::Address>
object.

=head2 ShipmentWeight

Shipment weight. Returns a L<Business::UPS::Tracking::Element::Weight>
object.

=head2 ShipToAddress

Shipment destination address. Returns a 
L<Business::UPS::Tracking::Element::Address> object.

=head2 ServiceCode

UPS service code. (eg. '002' for 2nd day air)

=head2 ServiceDescription

UPS service code description (eg. '2ND DAY AIR')

=head2 ShipmentReferenceNumber

Reference number for the whole shipment as provided by the shipper. Returns a 
L<Business::UPS::Tracking::Element::ReferenceNumber> object.

=cut

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
has 'ReferenceNumber' => (
    is      => 'ro',
    isa     => 'Business::UPS::Tracking::Element::ReferenceNumber',
    lazy    => 1,
    builder => '_build_ReferenceNumber',
);
has 'ShipmentIdentificationNumber' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_ShipmentIdentificationNumber',
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

sub _build_ReferenceNumber {
    my ($self) = @_;
    
    return Business::UPS::Tracking::Utils::build_referencenumber($self->xml,'ReferenceNumber');
}

sub _build_ShipmentIdentificationNumber {
    my ($self) = @_;

    return $self->xml->findvalue('ShipmentIdentificationNumber')
        || undef;
}

sub ShipmentType {
    Business::UPS::Tracking::X->throw("__PACKAGE__ is an abstract class")
}

__PACKAGE__->meta->make_immutable;

1;