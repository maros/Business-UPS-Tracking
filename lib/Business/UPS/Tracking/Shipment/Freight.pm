# ================================================================
package Business::UPS::Tracking::Shipment::Freight;
# ================================================================
use utf8;
use Moose;
use 5.0100;

extends 'Business::UPS::Tracking::Shipment';

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Shipment::Freight - A UPS freight shipment

=head1 DESCRIPTION

This class has not yet been implemented (Patches welcome).

This class represents an freight shipment and extends 
C<Business::UPS::Tracking::Shipment>. Usually it is created 
automatically from a L<Business::UPS::Tracking::Response> object.

=head1 ACCESSORS

Same as L<Business::UPS::Tracking::Shipment>


=cut

sub BUILD {
    warn('Business::UPS::Tracking::Shipment::Freight not yet implemented');   
    return;
}

=head1 METHODS

=head2 ShipmentType

Returns 'Freight'

=cut

sub ShipmentType {
    return 'Freight';
}

=head2 meta

Moose meta method

=cut

__PACKAGE__->meta->make_immutable;

1;