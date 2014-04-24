package Types::Evid;
$Types::Evid::VERSION = 'v0.0.1';
use Type::Library -base;
use Type::Utils -all;

use feature 'switch';
use experimental 'smartmatch';

BEGIN { extends "Types::Standard" }

class_type "DB_Subject", { class => 'Evid::Schema::Result::Subject' };
class_type "DB_User",    { class => 'Evid::Schema::Result::User' };
class_type "Datetime",   { class => 'DateTime' };
class_type "Element",    { class => 'Evid::Stamp::Element' };
class_type "Evid",       { class => 'Evid' };
class_type "PaperLog",   { class => 'Evid::Paper::Log' };
class_type "PathTiny",   { class => 'Path::Tiny' };
class_type "Stamp",      { class => 'Evid::Stamp' };
class_type "Subject",    { class => 'Evid::Subject' };
class_type "Tree",       { class => 'Tree::Simple' };

my @input_types = (
    qw{
        paragraph image text textarea password checkbox checkbox-inline
        checkbox-other checkbox-other-inline checkbox-image matrix/checkbox
        radio radio-inline radio-image matrix/radio select matrix/select
        html file none
        }
);

declare Input, as HashRef, where {
    my ( $type, $values, $file ) = ( $_->{type}, $_->{values}, $_->{file} );
    return unless $type;
    return unless grep { $type eq $_ } @input_types;

    if ($values) {
        return unless ref($values) eq 'ARRAY';
    }

    given ($type) {
        when (/checkbox/)  { return unless $values }
        when (/radio/)     { return unless $values }
        when (/select/)    { return unless $values }
        when (/paragraph/) { return unless $values }
        when (/html/)      { return unless $file }
        when (/image/) {
            return unless $values;
            for my $item (@$values) {
                return unless ref($item) eq 'HASH';
                return unless defined $item->{src};
            }
        }
    }

    return 1;
}, message {
    my ( $type, $values, $file ) = ( $_->{type}, $_->{values}, $_->{file} );

    return "Argument 'type' required" unless $type;
    return "Invalid type argument : $type"
        unless grep { $type eq $_ } @input_types;
    if ($values) {
        return "Argument 'values' is should be reference of Array"
            unless ref($values) eq 'ARRAY';
    }

    given ($type) {
        when (/paragraph/) {
            return q{Argument 'values' is required} unless $values;
        }
        when (/image/) {
            return q{Argument 'values' is required} unless $values;
            for my $item (@$values) {
                unless ( ref($item) eq 'HASH' ) {
                    return
                        q{Item of values's type is should be reference of Hash};
                }
                unless ( defined( $item->{src} ) ) {
                    return q{Attribute 'src' is required};
                }
            }

        }
        when (/checkbox/) {
            return q{Argument 'values' is required} unless $values;
        }
        when (/radio/) {
            return q{Argument 'values' is required} unless $values;
        }
        when (/html/) {
            return q{Argument 'file' is required} unless $file;
        }
    }
};

declare ElementName, as Str,
    where { length($_) >= 2 && lc $_ ne 'form' && $_ !~ / / };

declare ElementValidator, as CodeRef;

declare Sha1sum, as Str, where { length $_ == 40 };

1;
