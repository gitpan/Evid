package Evid::Stamp::Element::Validator;
$Evid::Stamp::Element::Validator::VERSION = 'v0.0.1';
use DateTime::Format::ISO8601;
use Try::Tiny;

sub or {
    my ( $self, $candidates ) = @_;
    return sub {
        my ( $input, $err ) = @_;
        for my $item ( @{ $candidates ||= [] } ) {
            return 1 if $item eq $input;
        }

        $$err = "$input is NOT IN " . join( " or ", @$candidates );
        return;
    };
}

sub range {
    my ( $self, $range ) = @_;
    return sub {
        my ( $input, $err ) = @_;
        if ( @$range < 2 ) {
            $$err = "range requires 2 args: MIN and MAX";
            return;
        }

        return unless $self->digit->( $input, $err );
        return 1 if $input >= $range->[0] && $input <= $range->[1];
        $$err = "$input is NOT between $range->[0] and $range->[1]";
        return;
    };
}

sub dateymd {
    my ($self) = @_;
    return sub {
        my ( $input, $err ) = @_;
        my $dt = try {
            DateTime::Format::ISO8601->parse_datetime($input);
        }
        catch {
            $$err
                = "<a href=\"http://en.wikipedia.org/wiki/ISO_8601\">ISO8601</a> date and time formats are allow";
            return;
        };

        return $dt;
    };
}

sub min {
    my ( $self, $min ) = @_;
    return sub {
        my ( $input, $err ) = @_;
        return unless $self->digit->( $input, $err );

        if ( $input < $min ) {
            $$err = "min: $min";
            return;
        }

        return 1;
    };
}

sub max {
    my ( $self, $max ) = @_;
    return sub {
        my ( $input, $err ) = @_;
        return unless $self->digit->( $input, $err );

        if ( $input > $max ) {
            $$err = "max: $max";
            return;
        }

        return 1;
    };
}

sub digit {
    my ($self) = @_;
    return sub {
        my ( $input, $err ) = @_;
        if ( $input !~ m/^\d+$/ ) {
            $$err = "only permit digit";
            return;
        }

        return 1;
    };
}

1;
