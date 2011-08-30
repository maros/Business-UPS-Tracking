# ============================================================================
package Business::UPS::Tracking::Meta::Attribute::Trait::Printable;
# ============================================================================
use utf8;
use 5.0100;

use Moose::Role;

our $VERSION = $Business::UPS::Tracking::VERSION;

package Moose::Meta::Attribute::Custom::Trait::Printable;
sub register_implementation { 'Business::UPS::Tracking::Meta::Attribute::Trait::Printable' }

no Moose::Role;
1;
