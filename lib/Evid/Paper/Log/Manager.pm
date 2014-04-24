package Evid::Paper::Log::Manager;
$Evid::Paper::Log::Manager::VERSION = 'v0.0.1';
use Moo;
use Types::Evid qw/ArrayRef Subject Stamp HashRef/;

with 'Evid::Role::Iterator';

use Evid::Constants;
use Evid::Paper::Log;
use Evid::Util;

has subject => ( is => 'ro', isa => Subject, required => 1 );
has stamp   => ( is => 'ro', isa => Stamp,   required => 1 );
has filter  => ( is => 'ro', isa => HashRef, default  => sub { {} } );

has '+_sequence' => ( isa => ArrayRef, init_arg => 'logs' );

sub BUILDARGS {
    my ( $class, %args ) = @_;
    my $subject = $args{subject};
    my $stamp   = $args{stamp};
    my $filter  = $args{filter};

    my ( $group, $parent ) = ( $filter->{group}, $filter->{parent} );
    my @lines = grep {
        my $log = Evid::Util::log_parse($_);
        if ( $group && $parent ) {
            $log->{group} eq $group && $log->{parent} eq $parent;
        }
        elsif ($group) {
            !$log->{parent} && $log->{group} eq $group;
        }
        elsif ($parent) {
            !$log->{group} && $log->{parent} eq $parent;
        }
        else {
            $log->{group} || $log->{parent} || 1;
        }
        } path("$Evid::Constants::SUBJECT_DIR/$subject/$stamp")
        ->touchpath->lines_utf8;

    my @logs = map { Evid::Paper::Log->new($_) } @lines;
    $args{logs} = [@logs];
    return {%args};
}

use overload '""' => sub {
    my $self = shift;
    my ( $subject, $stamp ) = ( $self->subject, $self->stamp );
    my ( $group, $parent )
        = ( $self->filter->{group}, $self->filter->{parent} );
    my $format = "%s/%s";
    my @args = ( "$subject", "$stamp" );
    if ($group) {
        $format .= '@%s';
        push @args, $group;
    }

    if ($parent) {
        $format .= '#%s';
        push @args, $parent;
    }

    return sprintf $format, @args;
};

sub head { shift->last }

sub add {
    my ( $self, $log ) = @_;
    my $subject = $self->subject;
    my $stamp   = $self->stamp;
    path("$Evid::Constants::SUBJECT_DIR/$subject/$stamp")
        ->touchpath->append_utf8("$log\n");
    $log->group( $self->filter->{group} );
    $log->parent( $self->filter->{parent} );
    $self->append($log);
    return $self;
}

1;
