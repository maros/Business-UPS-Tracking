# ================================================================
package Business::UPS::Tracking::Element::Weight;
# ================================================================
use utf8;
use Moose;
use 5.0100;


use Business::UPS::Tracking::Utils;

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Element::Weight - A shipment or package weight
  
=head1 DESCRIPTION

This class represents a declaration of weight. Usually it is created 
automatically from a L<Business::UPS::Tracking::Shipment> object.

=head1 ACCESSORS

=head2 xml

Original L<XML::LibXML::Node> node.

=head2 UnitOfMeasurementCode

Unit of measurement code

=head2 UnitOfMeasurementDescription

Unit of measurement string

=head2 Weight

Weight value (e.g. '5.50')

=cut

use overload '""' => \&_print, fallback => 1;

has 'xml' => (
    is       => 'rw',
    isa      => 'XML::LibXML::Node',
    required => 1,
    trigger  => \&_build_weight,
);
has 'UnitOfMeasurementCode'=> (
    is      => 'rw',
    isa     => 'Str',
);
has 'UnitOfMeasurementDescription'=> (
    is      => 'rw',
    isa     => 'Str',
);
has 'Weight'=> (
    is      => 'rw',
    isa     => 'Num',
);

sub _build_weight {
    my ($self,$xml) = @_;
    
    $self->UnitOfMeasurementCode($xml->findvalue('UnitOfMeasurement/Code'));
    $self->UnitOfMeasurementDescription($xml->findvalue('UnitOfMeasurement/Description'));
    $self->Weight($xml->findvalue('Weight'));
    
    return;
}

sub _print {
    my ($self) = @_;
    return $self->Weight.' '.$self->UnitOfMeasurementCode;
}

=head1 METHODS

=head2 meta

Moose meta method

=cut

__PACKAGE__->meta->make_immutable;

1;