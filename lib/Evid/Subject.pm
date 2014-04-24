package Evid::Subject;
$Evid::Subject::VERSION = 'v0.0.1';
use Moo;
use Types::Evid qw/Str Int Maybe Datetime DB_Subject/;

use Evid::Constants;
use Evid::Paper::Log::Manager;
use Evid::Util;

use DateTime;
use Path::Tiny;

=head1 SYNOPSIS

  my $subject = Evid::Subject->new(rs => $rs);    # Evid::Schema::Result::Subject
  # or
  my $subject = Evid::Subject->new(
      initial     => 'HHS',
      birthdate   => '1982-12-10',
      gender      => 1,    # 1: mail, 2: female
      enrolled_by => 'eslee'
  );

=head1 ATTRIBUTES

=head2 initial

=head2 birthdate

=head2 gender

=head2 enrolled_by

=head2 serial

=head2 rs

resultset.

=head2 status

=over

=item * created

set after C<Evid::Subject-E<gt>new>

=item * enrolled

set after C<$evid-E<gt>enroll($subject)>

=item * revoked

set after C<$evid-E<gt>revoke($subject)>

=back

C<created> 와 C<enrolled> 의 차이는 DB 에 들어갔는지의 여부입니다.
C<revoked> 는 들어갓다가 삭제된 경우입니다.

=cut

has initial     => ( is => 'rw', isa => Str );
has birthdate   => ( is => 'rw', isa => Str );
has gender      => ( is => 'rw', isa => Int );
has enrolled_by => ( is => 'rw', isa => Str );
has enrolldate  => ( is => 'rw', isa => Datetime );
has serial      => ( is => 'rw', isa => Str );
has status =>
    ( is => 'rw', isa => Str, default => $Evid::Constants::STATUS_CREATED );
has rs => ( is => 'rw', isa => Maybe [DB_Subject], trigger => 1 );

sub _trigger_rs {
    my ( $self, $rs ) = @_;
    unless ($rs) {
        $self->status($Evid::Constants::STATUS_REVOKED);
        $self->serial('');
        return;
    }

    my $data = $rs->data;
    map { $self->$_( $data->{$_} ) } qw/initial birthdate gender/;
    $self->enrolled_by( $rs->get_column('username') );
    $self->enrolldate( $rs->created_at );
    $self->status($Evid::Constants::STATUS_ENROLLED);
    my ( $sitename, $idx ) = ( $rs->sitename, $rs->idx );
    my $max = $ENV{EVID_MAX} || 10000;
    my $pad = '0' x ( length($max) - length($idx) );
    $self->serial( sprintf( "%s-%s", uc $sitename, $pad . $idx ) );
}

=head1 METHODS

=head2 stringify

=head2 to_hash

return HashRef for to create L<Evid::Schema::Result::Subject>

=head2 groups

피험자는 하나의 그룹에 여러번 배정이 가능

C<Random> 에 두번, C<Registry> 에 한번 배정되었다면,

  $subject->gruops    # { Random => [0, 1], Registry => [0] }

처럼 assignor 를 key 로 해서 배정번호를 줍니다.

=head2 logs

  my @logs = $subject->logs($stamp);

=head2 commit

  my $log = $subject->commit(
    stamp     => $stamp,
    group     => 'Random',
    parent    => $log,
    input     => '{"foo":"bar"}',
    timestamp => 1396933964,
    timezone  => '+0900',
    email     => 'aanoaa@gmail.com',
    author    => 'Hyungsuk Hong'
  );

=cut

use overload '""' => sub {
    my $self = shift;
    return $self->serial || sprintf( "%s(%s)<%s>#%s",
        $self->initial, $Evid::Constants::GENDER{ $self->gender },
        $self->birthdate, $self->enrolled_by );
};

sub to_hashref {
    my $self = shift;
    return { map { $_ => $self->$_ } qw/initial birthdate gender/ };
}

sub groups {
    my $self = shift;
    my $rs   = $self->rs;
    return unless $rs;

    my $groups  = {};
    my $sgroups = $rs->subject_groups;
    while ( my $sg = $sgroups->next ) {
        push @{ $groups->{ $sg->group->name } ||= [] }, $sg->idx;
    }

    return unless keys %$groups;
    return $groups;
}

sub logs {
    my ( $self, $stamp, $group, $parent ) = @_;
    return unless $stamp;
    return unless $self->serial;

    return Evid::Paper::Log::Manager->new(
        subject => $self,
        stamp   => $stamp,
        filter  => { group => $group, parent => $parent }
    );
}

sub commit {
    my ( $self, %args ) = @_;
    return
           unless $args{stamp}
        && $args{email}
        && $args{author}
        && $args{timestamp}
        && $args{timezone}
        && $args{input};

    my $logs = $self->logs( $args{stamp}, $args{group}, $args{parent} );
    return unless $logs;

    my ( $timestamp, $timezone )
        = ( delete $args{timestamp}, delete $args{timezone} );

    $args{timestamp} = DateTime->from_epoch( epoch => $timestamp );
    $args{timestamp}->set_time_zone($timezone);
    my $head = $logs->head;
    my $log  = Evid::Paper::Log->new(
        prev_hash => $head ? $head->hash : '0' x 40,
        hash => ( Evid::Util::add_content( $args{input} ) )[-1],
        %args
    );

    return $logs->add($log);
}

1;
