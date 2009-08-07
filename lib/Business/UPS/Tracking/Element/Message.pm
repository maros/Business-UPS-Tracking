# ================================================================
package Business::UPS::Tracking::Element::Message;
# ================================================================
use utf8;
use Moose;
use 5.0100;

use Business::UPS::Tracking::Utils;

our $VERSION = $Business::UPS::Tracking::VERISON;

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Element::Message - A small package message
  
=head1 DESCRIPTION

This class represents a message for a small package. Usually it is created 
automatically from a L<Business::UPS::Tracking::Element::Package> object.

=head1 ACCESSORS

=head2 xml

Original L<XML::LibXML::Node> node.

=head2 meta

Moose meta method

=cut

has 'xml' => (
    is       => 'rw',
    isa      => 'XML::LibXML::Node',
    required => 1,
    trigger  => \&_build_message,
);
has 'Code' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);
has 'Description' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

sub _build_message {
    my ( $self, $xml ) = @_;

    foreach my $node ( @{ $xml->childNodes } ) {
        my $name  = $node->nodeName;
        my $value = $node->textContent;
        next unless $self->can($name);
        next unless defined $value;
        $self->$name($value);
    }

    return;
}

=head1 METHODS

=head2 Status 

=cut


=head2 meta

Moose meta method

=cut

__PACKAGE__->meta->make_immutable;

1;
