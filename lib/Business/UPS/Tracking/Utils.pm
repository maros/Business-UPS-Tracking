# ================================================================
package Business::UPS::Tracking::Utils;
# ================================================================
use utf8;
use Moose;
use 5.0100;

use Business::UPS::Tracking;
use Business::UPS::Tracking::Element::Address;
use Business::UPS::Tracking::Element::Weight;
use Business::UPS::Tracking::Element::ReferenceNumber;

our $VERSION = $Business::UPS::Tracking::VERISON;

=encoding utf8

=head1 NAME

Business::UPS::Tracking::Utils - Utility functions

=head1 SYNOPSIS

 use Business::UPS::Tracking::Utils;
 
=head1 DESCRIPTION

This module provides some basic utility functions for 
L<Business::UPS::Tracking> and defines some Moose type constraints and 
coercions as well as the exception classes.
 
=head1 FUNCTIONS

=cut

use Moose::Util::TypeConstraints;

subtype 'XMLDocument' => as class_type('XML::LibXML::Document');

coerce 'XMLDocument' 
    => from 'Str' 
    => via {
        my $parser = XML::LibXML->new();
        my $doc = eval {
            $parser->parse_string($_);
        };
        if (! $doc) {
            Business::UPS::Tracking::X::XML->throw($@ || 'Unknown error parsing xml document');
        }
        return $doc;
    };
    
subtype 'Date' 
    => as class_type('DateTime');

subtype 'DateStr' 
    => as 'Str' 
    => where {
        m/^ 
            (19|20)\d\d #year
            (0[1-9]|1[012]) #month
            (3[01]|[12]\d|0[1-9]) #day
        $/x;
    };

coerce 'DateStr' 
    => from 'Date' 
    => via {
        return $_->format_cldr('yyyyMMdd');
    };

subtype 'TrackingNumber'
    => as 'Str'
    => where { m/^1Z.+$/ }
    => message { "Tracking numbers must start with '1Z'" };

subtype 'CountryCode'
    => as 'Str'
    => where { m/^[A-Z]{2}$/ }
    => message { "Must be an uppercase ISO 3166-1 alpha-2 code" };

use Exception::Class( 
    'Business::UPS::Tracking::X'    => {
        description   => 'Basic error'
    },
    'Business::UPS::Tracking::X::HTTP' => {
        isa           => 'Business::UPS::Tracking::X',    
        description   => 'HTTP error',
        fields        => ['http_response','request']
    },
    'Business::UPS::Tracking::X::UPS'  => {
        isa           => 'Business::UPS::Tracking::X',    
        description   => 'UPS error',
        fields        => ['code','severity','request','context']
    },
    'Business::UPS::Tracking::X::XML'  => {
        isa           => 'Business::UPS::Tracking::X',    
        description   => 'Malformed response xml',
    },
);

=head3 parse_date

 $datetime = parse_date($string);

Parses a date string (YYYYMMDD) and returns a L<DateTime> object.

=cut

sub parse_date {
    my $datestr = shift;
    
    return
        unless $datestr
        && $datestr =~ m/^
            (?<year>(19|20)\d\d)
            (?<month>0[1-9]|1[012])
            (?<day>3[01]|[12]\d|0[1-9])
        $/x;
    
    my $date;
    $date = eval {
        DateTime->new(
            year    => $+{year},
            month   => $+{month},
            day     => $+{day},
        );
    };
    if (! $date || $@) {
        Business::UPS::Tracking::X::XML->throw("Invalid date string '$datestr' : $@");
    }
    return $date;
}

=head3 parse_time

 $datetime = parse_time($string,$datetime);

Parses a time string (HHMMSS) and appends the parsed values to the given
L<DateTime> object

=cut

sub parse_time {
    my ($timestr,$datetime) = @_;
    
    return 
        unless $datetime;
    
    return $datetime
        unless $timestr 
        && $timestr =~ m/^
            (?<hour>\d\d)
            (?<minute>\d\d)
            (?<second>\d\d)
        $/x;
    
    my $success = eval {
        $datetime->set_hour( $+{hour} );
        $datetime->set_minute( $+{minute} );
        $datetime->set_second( $+{second} );
        return 1;
    };
    if (! $success || $@) {
        Business::UPS::Tracking::X::XML->throw("Invalid time string '$timestr' : $@");
    }

    return $datetime;
}

=head3 build_address

 my $address = build_address($libxml_node,$xpath_expression);

Turns an address xml node into a L<Business::UPS::Tracking::Element::Address> 
object.

=cut

sub build_address {
    my ($xml,$xpath) = @_;
    
    my $node = $xml->findnodes($xpath)->get_node(1);
    
    return 
        unless $node && ref $node;
        
    return Business::UPS::Tracking::Element::Address->new(
        xml => $node,
    );
}

=head3 build_weight

 my $weight = build_weight($libxml_node,$xpath_expression);

Turns an weight xml node into a L<Business::UPS::Tracking::Element::Weight> 
object.

=cut

sub build_weight {
    my ($xml,$xpath) = @_;
    
    my $node = $xml->findnodes($xpath)->get_node(1);
    
    return 
        unless $node && ref $node;
        
    return Business::UPS::Tracking::Element::Weight->new(
        xml => $node,
    );
}

=head3 build_referencenumber

 my $weight = build_referencenumber($libxml_node,$xpath_expression);

Turns an weight xml node into a 
L<Business::UPS::Tracking::Element::ReferenceNumber> object.

=cut

sub build_referencenumber {
    my ($xml,$xpath) = @_;
    
    my $node = $xml->findnodes($xpath)->get_node(1);
    
    return 
        unless $node && ref $node;
        
    return Business::UPS::Tracking::Element::ReferenceNumber->new(
        xml => $node,
    );
}

=head3 escape_xml

 my $escaped_string = escape_xml($string);

Escapes a string for xml

=cut

sub escape_xml {
    my ($string) = @_;
    
    $string =~ s/&/&amp;/g;
    $string =~ s/</&gt;/g;
    $string =~ s/>/&lt;/g;
    $string =~ s/"/&qout;/g;
    $string =~ s/'/&apos;/g;
    
    return $string;
}

1;