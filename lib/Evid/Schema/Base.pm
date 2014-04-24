package Evid::Schema::Base;
# ABSTRACT: Evid is a deployable and customizable e-CRF service.
# VERSION
$Evid::Schema::Base::VERSION = 'v0.0.1';
use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components(
    qw/InflateColumn::DateTime TimeStamp InflateColumn::Serializer/);

1;

=head1 NAME

Evid::Schema::Base - Base Module of Evid::Schema::Result

=cut
