# ============================================================================
package Business::UPS::Tracking::Meta::Attribute::Trait::Serializable;
# ============================================================================
use utf8;
use 5.0100;

use Moose::Role;
use strict; # Make cpants happy

our $VERSION = $Business::UPS::Tracking::VERISON;

has 'serialize' => (
    is          => 'rw',
    isa         => 'CodeRef',
    predicate   => 'has_serialize',
);

package Moose::Meta::Attribute::Custom::Trait::Serializable;
sub register_implementation { 'Business::UPS::Tracking::Meta::Attribute::Trait::Serializable' }

no Moose::Role;
1;