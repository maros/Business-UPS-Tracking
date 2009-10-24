# ============================================================================
package Business::UPS::Tracking::Utils;
# ============================================================================
use utf8;
use 5.0100;

use metaclass (
    metaclass   => "Moose::Meta::Class",
    error_class => "Business::UPS::Tracking::Exception",
);
use Moose;

use Moose::Util::TypeConstraints;
use Business::UPS::Tracking;
use MooseX::Getopt::OptionTypeMap;
use Business::UPS::Tracking::Meta::Attribute::Trait::Serializable;

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



subtype 'XMLDocument' => as class_type('XML::LibXML::Document');

coerce 'XMLDocument' 
    => from 'Str' 
    => via {
        my $xml = $_;
        my $parser = XML::LibXML->new();
        my $doc = eval {
            $parser->parse_string($xml);
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
    => where { 
        my $trackingnumber = $_;
        return 0 
            unless ($trackingnumber =~ m/^1Z(?<tracking>[A-Z0-9]{8}\d{7})(?<checksum>\d)$/); 
        # Checksum check fails because UPS testdata has invalid checksum!
        return 1    
            unless $Business::UPS::Tracking::CHECKSUM;
        my $checksum = $+{checksum};
        my $tracking = $+{tracking}; 
        $tracking =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZ/23456789012345678901234567/;
        my ($odd,$even,$pos) = (0,0,0);
        foreach (split //,$tracking) {
            $pos ++;
            if ($pos % 2) {
                $odd += $_;
            } else {
                $even += $_;
            }
        }
        $even *= 2;
        my $calculated = $odd + $even;
        $calculated =~ s/^\d+(\d)$/$1/e;
        $calculated = 10 - $calculated
            unless ($calculated == 0);
        return ($checksum == $calculated);
    }
    => message { "Tracking numbers must start withn '1Z', contain 14 additional characters and end with a valid checksum" };

subtype 'CountryCode'
    => as 'Str'
    => where { m/^[A-Z]{2}$/ }
    => message { "Must be an uppercase ISO 3166-1 alpha-2 code" };



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

__PACKAGE__->meta->make_immutable;

1;