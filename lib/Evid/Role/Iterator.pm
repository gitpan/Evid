package Evid::Role::Iterator;
$Evid::Role::Iterator::VERSION = 'v0.0.1';
use Moo::Role;
use Types::Evid qw/ArrayRef Any Int/;

use Path::Tiny;

has _pos => ( is => 'rw', isa => Int, default => sub {-1} );

has '_sequence' => ( is => 'rw', isa => ArrayRef [Any], required => 1, );

sub all { return @{ (shift)->_sequence } }
sub count { return scalar @{ (shift)->_sequence } }

sub first {
    my $self = shift;

    $self->_pos(0);
    return $self->_sequence->[$self->_pos];
}

sub last {
    my $self = shift;

    $self->_pos( $self->count - 1 );
    return $self->_sequence->[$self->_pos];
}

sub next {
    my $self = shift;

    return unless $self->has_next;
    my $pos = $self->_pos;

    return if ++$pos == $self->count;

    $self->_pos($pos);
    return $self->_sequence->[$pos];
}

sub has_next {
    my $self = shift;
    return ( $self->_pos < ( $self->count - 1 ) );
}

sub append {
    my ( $self, $item ) = @_;
    push @{ $self->_sequence }, $item;
}

1;
