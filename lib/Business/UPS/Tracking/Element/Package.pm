# ================================================================
package Business::UPS::Tracking::Element::Package;
# ================================================================
use utf8;
use Moose;
use 5.0100;

use Business::UPS::Tracking::Utils;
use Business::UPS::Tracking::Element::Activity;

our $VERSION = $Business::UPS::Tracking::VERISON;

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Element::Package - A small freight package
  
=head1 DESCRIPTION

This class represents an small freight package. Usually it is created 
automatically from a L<Business::UPS::Tracking::Shipment> object.

=head1 ACCESSORS

=head2 xml

Original L<XML::LibXML::Node> node.

=head2 Activity 

Arrayref of L<Business::UPS::Tracking::Element::Activity> objects
ordered by activity date and time. Check the first element in the list for the
most recent status. 

=head2 RescheduledDelivery

Date and time of rescheduled delivery attempt. Returns a L<DateTime> object.

Returns a L<Business::UPS::Tracking::Element::Address> object.

=head2 ReturnToAddress

Returns a L<Business::UPS::Tracking::Element::Address> object.

=head2 SignatureRequired

Returns 'A' (adult signature), 'S' (signature) or undef (no signature 
required).

=head2 PackageWeight

Package weight. Returns a L<Business::UPS::Tracking::Element::Weight> object.

=head2 TrackingNumber

UPS tracking number.

=head2 RerouteAddress

Returns a L<Business::UPS::Tracking::Element::Address> object.

=head1 METHODS

=head2 meta

Moose meta method

=cut

has 'xml' => (
    is       => 'ro',
    isa      => 'XML::LibXML::Node',
    required => 1,
);
has 'RerouteAddress' => (
    is    => 'ro',
    isa   => 'Maybe[Business::UPS::Tracking::Address]',
    lazy  => 1,
    builder => '_build_RerouteAddress',
);
has 'ReturnToAddress' => (
    is    => 'ro',
    isa   => 'Maybe[Business::UPS::Tracking::Address]',
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
#has 'Message' => (
#    is    => 'ro',
#    isa   => 'ArrayRef[Business::UPS::Tracking::Element::Message]',
#    lazy  => 1,
#    builder => '_build_Message',
#);
has 'PackageWeight' => (
    is    => 'ro',
    isa   => 'Maybe[Business::UPS::Tracking::Element::Weight]',
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
    isa   => 'Maybe[Str]',
    lazy  => 1,
    builder => '_build_ProductTypeCode',
);
has 'ProductTypeDescription' => (
    is    => 'ro',
    isa   => 'Maybe[Str]',
    lazy  => 1,
    builder => '_build_ProductTypeDescription',
);
has 'TrackingNumber' => (
    is  => 'ro',
    isa => 'Maybe[TrackingNumber]',
    lazy  => 1,
    builder => '_build_TrackingNumber',
);
has 'RescheduledDelivery' => (
    is      => 'ro',
    isa     => 'Maybe[Date]',
    lazy    => 1,
    builder => '_build_RescheduledDelivery',
);

sub _build_RerouteAddress {
    my ($self) = @_;

    return Business::UPS::Tracking::Utils::build_address( $self->xml,
        'Reroute/Address' );
}

sub _build_ReturnToAddress {
    my ($self) = @_;

    return Business::UPS::Tracking::Utils::build_address( $self->xml,
        'ReturnTo/Address' );
}

sub _build_PackageWeight {
    my ($self) = @_;

    return Business::UPS::Tracking::Utils::build_weight( $self->xml,
        'PackageWeight' );
}

#sub _build_Message {
#    my ($self) = @_;
#
#    my @nodes = $self->xml->findnodes('Message');
#    my $return = [];
#    foreach my $node (@nodes) {
#        push @$return,Business::UPS::Tracking::Element::Message->new(
#            xml => $node,
#        );
#    }
#    return $return;
#}



sub _build_Activity {
    my ($self) = @_;

    my @nodes = $self->xml->findnodes('Activity');
    my $return = [];
    my @temp;
    
    foreach my $node (@nodes) {
        push @temp,Business::UPS::Tracking::Element::Activity->new(
            xml => $node,
        );
    }
    return [ sort { $b->DateTime <=> $a->DateTime } @temp ];
}

sub _build_SignatureRequired {
    my ($self) = @_;

    return $self->xml->findvalue('PackageServiceOptions/SignatureRequired/Code')
        || undef;
}

sub _build_ProductTypeCode {
    my ($self) = @_;

    return $self->xml->findvalue('ProductType/Code')
        || undef;
}

sub _build_ProductTypeDescription {
    my ($self) = @_;

    return $self->xml->findvalue('ProductType/Description')
        || undef;
}

sub _build_ReferenceNumber {
    my ($self) = @_;
    
    my @nodes = $self->xml->findnodes('ReferenceNumber');
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
    return $self->xml->findvalue('TrackingNumber');
}


sub _build_RescheduledDelivery {
    my ($self) = @_;

    my $datestr = $self->xml->findvalue('RescheduledDeliveryDate');
    my $date    = Business::UPS::Tracking::Utils::parse_date($datestr);

    my $timestr = $self->xml->findvalue('RescheduledDeliveryTime');
    $date = Business::UPS::Tracking::Utils::parse_time( $timestr, $date );

    return $date;
}




=head1 METHODS

=head2 CurrentStatus

Returns the last known status. Can return

=over

=item * In Transit

=item * Delivered

=item * Exeption

=item * Pickup

=item * Manifest Pickup

=item * Unknown

=back

If you need to obtain more detailed information on the current status use
C<$pakcage-E<gt>Activity-E<gt>[0]-<gt>StatusTypeDescription>,
C<$pakcage-E<gt>Activity-E<gt>[0]-<gt>StatusCode> and
C<$pakcage-E<gt>Activity-E<gt>[0]-<gt>DateTime>.

=cut

sub CurrentStatus {
    my ($self) = @_;
    
    my $activities = $self->Activity;
  
    if (defined $activities 
        && ref $activities eq 'ARRAY') {
        return $activities->[0]->Status;
    } else {
        return 'Unknown';
    }
}

=head2 meta

Moose meta method

=cut

__PACKAGE__->meta->make_immutable;

1;
