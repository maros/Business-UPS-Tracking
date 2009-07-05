# ================================================================
package Business::UPS::Tracking;
# ================================================================
use utf8;
use Moose;
use 5.0100;

use LWP::UserAgent;
use Business::UPS::Tracking::Utils;
use Business::UPS::Tracking::Request;

use version;
use vars qw($VERSION);
$VERSION = version->new('1.00');

=encoding utf8

=head1 NAME

Business::UPS::Tracking - Interface to UPS Tracking webservice

=head1 SYNOPSIS

  use Business::UPS::Tracking;
  
  my $tracking = Business::UPS::Tracking->new(
    license  => '',
    username => 'myupsuser',
    password => 'secret',
  );
  
  eval {
    my $response = $tracking->request(
      TrackingNumber  => '1Z12345E1392654435',
    )->run();
    say 'Delivery scheduled for '.$response->shipment->ScheduledDelivery->dmy();
  };
  
  if (my $e = Exception::Class->caught) {
    given ($e) {
      when ($_->isa('Business::UPS::Tracking::X::HTTP')) {
        say 'HTTP ERROR:'.$e->full_message;
      }
      when ($_->isa('Business::UPS::Tracking::X::UPS')) {
        say 'DPD ERRPR:'.$e->full_message.' ('.$e->code.')';
      }
      default {
        say 'SOME ERROR:'.$e;
      }        
    }
  }

=head1 DESCRIPTION

=head2 Class structure

                     .-----------------------------------.
                     |     Business::UPS::Tracking       |
                     '-----------------------------------'
                                     ^
                                  HAS ONE 
                                     |
                     .-----------------------------------.
                     |         B::U::T::Request          |
                     '-----------------------------------'
                                     ^
                                  HAS ONE
                                     |
                     .-----------------------------------.
                     |         B::U::T::Response         |
                     '-----------------------------------'
                                     |
                                  HAS MANY
                                     v
                     .-----------------------------------.
                     |         B::U::T::Shipment         |
                     '-----------------------------------'
                         ^                           ^
                        ISA                         ISA
                         |                           |
   .---------------------------------. .-----------------------------------.
   |    B::U::T::Shipment::Freight   | |  B::U::T::Shipment::Smallpackage  |
   |---------------------------------| |-----------------------------------|
   | Freight shipment type           | | Small package shipment type       |
   | Not yet implemented             | '-----------------------------------'
   '---------------------------------'               |
                                                  HAS MANY
                                                     v
                                      .-----------------------------------.
                                      |     B::U::T::Element::Package     |
                                      '-----------------------------------'
                                                     |
                                                  HAS MANY
                                                     v
                                      .-----------------------------------.
                                      |    B::U::T::Element::Activity     |
                                      '-----------------------------------'

=head2 Exception Handling

If anythis goes wrong Business::UPS::Tracking throws an exception. Exceptions 
are allways L<Exception::Class> object which contain stuctured information
about the error. Please refer to the synopsis or L<Exception::Class> 
documentation for documentation how to catch and rethrow exeptions.

The following exception classes are defined:

=over

=item * Business::UPS::Tracking::X

Basic exception class. All other exception classes inherit from this class.

=item * Business::UPS::Tracking::X::HTTP

HTTP error. The object provides additional parameters:

=over

=item * http_response : L<HTTP::Response> object

=item * request : L<Business::UPS::Tracking::Request> object

=back

=item * Business::UPS::Tracking::X::UPS

UPS error message.The object provides additional parameters:

=over

=item * code : UPS error code

=item * severity : Error severity 'hard' or 'soft'

=item * context : L<XML::LibXML::Node> object containing the whole error response.

=item * request : L<Business::UPS::Tracking::Request> object

=back

=item * Business::UPS::Tracking::X::XML

XML parser or schema error.

=back

=head2 Accessor / method nameing

The nameing of the methods and accessors tries to stick close to the names
used by the UPS webservice. All accessors containg uppercase letters access
xml data. Lowercase-only accessors and methods are used for utility 
functions.

=head2 UPS license

In order to use this module you need to obtain a "Tracking WebService" 
license key. See L<http://www.ups.com/e_comm_access/gettools_index> for more
inforation.

=head1 METHODS

=head2 new 

 my $tracking = Business::UPS::Tracking->new(%params);

Create a C<Business::UPS::Tracking> object. See L<ACCESSORS> for available
parameters.

=head2 access_request

UPS access request.

=head2 request

 my $request = $tracking->request(%request_params);

Returns a L<Business::UPS::Tracking::Request> object. 

=head2 request_run

 my $response = $tracking->request_run(%request_params);

Generates a L<Business::UPS::Tracking::Request> object and imideately 
executes it, returning a L<Business::UPS::Tracking::Response> object. 

=head1 ACCESSORS

=head2 AccessLicenseNumber

UPS tracking service access license number

=head2 UserId

UPS account username

=head2 Password

UPS account password

=head2 retry_http

Number of retries if http errors occur

Defaults to 0

=head2 url

UPS Tracking webservice url.

Defaults to https://wwwcie.ups.com/ups.app/xml/Track

=head2 _ua

L<LWP::UserAgent> object.

Automatically generated

=cut

has 'AccessLicenseNumber' => (
    is       => 'rw',
    required => 1,
    isa      => 'Str',
);
has 'UserId' => (
    is       => 'rw',
    required => 1,
    isa      => 'Str',
);
has 'Password' => (
    is       => 'rw',
    required => 1,
    isa      => 'Str',
);
has 'retry_http' => (
    is      => 'rw',
    isa     => 'Int',
    default => 0,
);
has 'url' => (
    is      => 'rw',
    default => 'https://wwwcie.ups.com/ups.app/xml/Track'
);
has '_ua' => (
    is      => 'rw',
    lazy    => 1,
    isa     => 'LWP::UserAgent',
    builder => '_build_ua',
);

sub _build_ua {
    my ($self) = @_;

    my $ua = LWP::UserAgent->new(
        agent       => "__PACKAGE__ $VERSION",
        timeout     => 50,
        env_proxy   => 1,
    );

    return $ua;
}

sub access_request {
    my ($self) = @_;

    my $license = Business::UPS::Tracking::Utils::escape_xml($self->AccessLicenseNumber);
    my $username = Business::UPS::Tracking::Utils::escape_xml($self->UserId);
    my $password = Business::UPS::Tracking::Utils::escape_xml($self->Password);
    
    return <<ACR
<?xml version="1.0"?>
<AccessRequest xml:lang='en-US'>
    <AccessLicenseNumber>$license</AccessLicenseNumber>
    <UserId>$username</UserId>
    <Password>$password</Password>
</AccessRequest>
ACR
}

sub request {
    my ( $self, %params ) = @_;
    return Business::UPS::Tracking::Request->new( 
        %params, 
        tracking => $self,
    );
}

sub request_run {
    my ( $self, %params ) = @_;
    return $self->request(%params)->run();
}

__PACKAGE__->meta->make_immutable;

=head1 SUPPORT

Please report any bugs or feature requests to 
C<bug-buisness-ups-tracking@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=Business::UPS::Tracking>.  
I will be notified, and then you'll automatically be notified of progress on 
your report as I make changes.

=head1 AUTHOR

    Maroš Kollár
    CPAN ID: MAROS
    maros [at] k-1.com
    http://www.k-1.com

=head1 ACKNOWLEDGEMENTS 

This module was written for Revdev L<http://www.revdev.at>, a nice litte 
software company I run with Koki and Domm (L<http://search.cpan.org/~domm/>).


=head1 COPYRIGHT

Business::UPS::Tracking is Copyright (c) 2009 Maroš Kollár.

This program is free software; you can redistribute it and/or modify it under 
the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included with 
this module.

=head1 SEE ALSO

Download the UPS ""OnLine® Tools Tracking Developer Guide"" and get a
developer key at L<http://www.ups.com/e_comm_access/gettools_index?loc=en_US>. 
Please check the "Developer Guide" for more detailed documentation on the
various fields.

The L<WebService::UPS::TrackRequest> provides an alternative simpler 
implementation.

=cut

'https://wwwcie.ups.com/ups.app/xml/Track';
