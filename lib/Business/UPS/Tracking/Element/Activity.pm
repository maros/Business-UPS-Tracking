# ================================================================
package Business::UPS::Tracking::Element::Activity;
# ================================================================
use utf8;
use Moose;
use 5.0100;

use Business::UPS::Tracking::Utils;
use Business::UPS::Tracking::Element::Activity;

our $VERSION = $Business::UPS::Tracking::VERISON;

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Element::Activity - A small freight package activity
  
=head1 DESCRIPTION

This class represents an small freight package activity. Usually it is created 
automatically from a L<Business::UPS::Tracking::Shipment> object.

=head1 ACCESSORS

=head2 xml

Original L<XML::LibXML::Node> node.

=head2 ActivityLocationAddress

A L<Business::UPS::Tracking::Element::Address> object representing the 
location of the activity.

=head2 ActivityLocationCode

=head2 ActivityLocationDescription

=head2 SignedForByName

=head2 StatusCode

=head2 StatusTypeCode

=head2 StatusTypeDescription

=head2 DateTime

L<DateTime> object.

=head1 METHODS

=head2 meta

Moose meta method

=cut

has 'xml' => (
    is       => 'ro',
    isa      => 'XML::LibXML::Node',
    required => 1,
);

has 'ActivityLocationAddress' => (
    is      => 'ro',
    isa     => 'Maybe[Business::UPS::Tracking::Element::Address]',
    lazy    => 1,
    builder => '_build_ActivityLocationAddress',
);
has 'ActivityLocationCode' => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    lazy    => 1,
    builder => '_build_ActivityLocationCode',
);
has 'ActivityLocationDescription' => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    lazy    => 1,
    builder => '_build_ActivityLocationDescription',
);
has 'SignedForByName' => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    lazy    => 1,
    builder => '_build_SignedForByName',
);
has 'StatusCode' => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    lazy    => 1,
    builder => '_build_StatusCode',
);
has 'StatusTypeCode' => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    lazy    => 1,
    builder => '_build_StatusTypeCode',
);
has 'StatusTypeDescription' => (
    is      => 'ro',
    isa     => 'Maybe[Str]',
    lazy    => 1,
    builder => '_build_StatusTypeDescription',
);
has 'DateTime' => (
    is      => 'ro',
    isa     => 'Maybe[Date]',
    lazy    => 1,
    builder => '_build_DateTime',
);

sub _build_DateTime {
    my ($self) = @_;

    my $datestr = $self->xml->findvalue('Date');
    my $date    = Business::UPS::Tracking::Utils::parse_date($datestr);

    my $timestr = $self->xml->findvalue('Time');
    return Business::UPS::Tracking::Utils::parse_time( $timestr, $date );
}

sub _build_StatusTypeDescription {
    my ($self) = @_;

    return $self->xml->findvalue('Status/StatusType/Description');
}

sub _build_StatusTypeCode {
    my ($self) = @_;

    return $self->xml->findvalue('Status/StatusType/Code');
}

sub _build_StatusCode {
    my ($self) = @_;

    return $self->xml->findvalue('Status/StatusCode/Code');
}

sub _build_ActivityLocationAddress {
    my ($self) = @_;

    return Business::UPS::Tracking::Utils::build_address( $self->xml,
        'ActivityLocation/Address' );
}

sub _build_ActivityLocationDescription {
    my ($self) = @_;

    return $self->xml->findvalue('ActivityLocation/Description');
}

sub _build_ActivityLocationCode {
    my ($self) = @_;

    return $self->xml->findvalue('ActivityLocation/Code');
}

sub _build_SignedForByName {
    my ($self) = @_;

    return $self->xml->findvalue('ActivityLocation/SignedForByName');
}

=head1 METHODS

=head2 Status

Translates the L<StatusTypeCode> to a short description. Can return

=over

=item * In Transit

=item * Delivered

=item * Exeption

=item * Pickup

=item * Manifest Pickup

=item * Unknown

=back

=cut

sub Status {
    my ($self) = @_;
    
    given ($self->StatusTypeCode) {
        when ('I') {
            return 'In Transit';
        }
        when ('D') {
            return 'Delivered';
        }
        when ('X') {
            return 'Exeption';
        }
        when ('P') {
            return 'Pickup';
        }
        when ('M') {
            return 'Manifest Pickup';
        }
        default {
            return 'Unknown';
        }
    }
}

=head2 meta

Moose meta method

=cut


__PACKAGE__->meta->make_immutable;

1;
