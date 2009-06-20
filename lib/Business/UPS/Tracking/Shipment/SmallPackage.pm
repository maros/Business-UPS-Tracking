# ================================================================
package Business::UPS::Tracking::Shipment::SmallPackage;
# ================================================================
use utf8;
use Moose;
use 5.0100;

extends 'Business::UPS::Tracking::Shipment';

use Business::UPS::Tracking::Element::Activity;

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Shipment::SmallPackage - A UPS small package shipment

=head1 DESCRIPTION


This class represents an small package shipment and extends 
C<Business::UPS::Tracking::Shipment>. Usually it is created 
automatically from a L<Business::UPS::Tracking::Response> object.

=head1 ACCESSORS

Same as L<Business::UPS::Tracking::Shipment>

=cut

has 'RescheduledDelivery' => (
    is      => 'ro',
    isa     => 'Date',
    lazy    => 1,
    builder => '_build_RescheduledDelivery',
);
has 'ShipmentIdentificationNumber' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_ShipmentIdentificationNumber',
);
has 'RerouteAddress' => (
    is    => 'ro',
    isa   => 'Business::UPS::Tracking::Address',
    lazy  => 1,
    builder => '_build_RerouteAddress',
);
has 'ReturnToAddress' => (
    is    => 'ro',
    isa   => 'Business::UPS::Tracking::Address',
    lazy  => 1,
    builder => '_build_ReturnToAddress',
);
has 'Activity' => (
    is    => 'ro',
    isa   => 'ArrayRef[Business::UPS::Tracking::Element::Activity]',
    lazy  => 1,
    builder => '_build_Activity',
);
has 'SignatureRequired' => (
    is    => 'ro',
    isa   => 'Str',
    lazy  => 1,
    builder => '_build_SignatureRequired',
);
has 'Message' => (
    is    => 'ro',
    isa   => 'ArrayRef[Business::UPS::Tracking::Element::Message]',
    lazy  => 1,
    builder => '_build_Message',
);
has 'PackageWeight' => (
    is    => 'ro',
    isa   => 'Business::UPS::Tracking::Element::Weight',
    lazy  => 1,
    builder => '_build_PackageWeight',
);
has 'ReferenceNumber' => (
    is      => 'ro',
    isa     => 'ArrayRef[Business::UPS::Tracking::Element::ReferenceNumber]',
    lazy    => 1,
    builder => '_build_ReferenceNumber',
);
has 'ProductTypeCode' => (
    is    => 'ro',
    isa   => 'Str',
    lazy  => 1,
    builder => '_build_ProductTypeCode',
);
has 'ProductTypeDescription' => (
    is    => 'ro',
    isa   => 'Str',
    lazy  => 1,
    builder => '_build_ProductTypeDescription',
);
has 'TrackingNumber' => (
    is  => 'ro',
    isa => 'TrackingNumber',
    lazy  => 1,
    builder => '_build_TrackingNumber',
);

sub _build_RescheduledDelivery {
    my ($self) = @_;

    my $datestr = $self->xml->findvalue('Package/RescheduledDeliveryDate');
    my $date    = Business::UPS::Tracking::Utils::parse_date($datestr);

    my $timestr = $self->xml->findvalue('Package/RescheduledDeliveryTime');
    $date = Business::UPS::Tracking::Utils::parse_time( $timestr, $date );

    return $date;
}

sub _build_ShipmentIdentificationNumber {
    my ($self) = @_;

    return $self->xml->findvalue('ShipmentIdentificationNumber')
        || undef;
}

sub _build_RerouteAddress {
    my ($self) = @_;

    return Business::UPS::Tracking::Utils::build_address( $self->xml,
        'Package/Reroute/Address' );
}

sub _build_ReturnToAddress {
    my ($self) = @_;

    return Business::UPS::Tracking::Utils::build_address( $self->xml,
        'Package/ReturnTo/Address' );
}

sub _build_PackageWeight {
    my ($self) = @_;

    return Business::UPS::Tracking::Utils::build_weight( $self->xml,
        'Package/PackageWeight' );
}

sub _build_Message {
    my ($self) = @_;

    my @nodes = $self->xml->findnodes('Package/Message');
    my $return = [];
    foreach my $node (@nodes) {
        push @$return,Business::UPS::Tracking::Element::Message->new(
            xml => $node,
        );
    }
    return $return;
}


sub _build_Activity {
    my ($self) = @_;

    my @nodes = $self->xml->findnodes('Package/Activity');
    my $return = [];
    foreach my $node (@nodes) {
        push @$return,Business::UPS::Tracking::Element::Activity->new(
            xml => $node,
        );
    }
    return $return;
}

sub _build_SignatureRequired {
    my ($self) = @_;

    return $self->xml->findvalue('Package/PackageServiceOptions/SignatureRequired/Code')
        || undef;
}

sub _build_ProductTypeCode {
    my ($self) = @_;

    return $self->xml->findvalue('Package/ProductType/Code')
        || undef;
}

sub _build_ProductTypeDescription {
    my ($self) = @_;

    return $self->xml->findvalue('Package/ProductType/Description')
        || undef;
}

sub _build_ReferenceNumber {
    my ($self) = @_;
    
    my @nodes = $self->xml->findnodes('Package/ReferenceNumber');
    my $return = [];
    foreach my $node (@nodes) {
        push @$return,Business::UPS::Tracking::Element::ReferenceNumber->new(
            xml => $node,
        );
    }
    return $return;
 }

sub _build_TrackingNumber {
    my ($self) = @_;
    
    return $self->xml->findvalue('Package/TrackingNumber');
}

=head1 METHODS

=head2 ShipmentType

Returns 'Small Package'

=cut

sub ShipmentType {
    return 'Small Package';
}

=head2 meta

Moose meta method

=cut

__PACKAGE__->meta->make_immutable;

1;
