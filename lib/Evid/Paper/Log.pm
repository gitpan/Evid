package Evid::Paper::Log;
$Evid::Paper::Log::VERSION = 'v0.0.1';
use Moo;
use Types::Evid qw/Str Datetime Sha1sum/;

use DateTime;
use Path::Tiny;

use Evid::Constants;
use Evid::Util;

=head1 SYNOPSIS

  # /path/to/PAPER/ASAN-00001/23ec504
  # <PREV-OBJECT-REF> <OBJECT-REF> <AUTHOR> <EMAIL> <TIMESTAMP> <TIMEZONE> <GROUP> <PARENT>
  0000000000000000000000000000000000000000 c3e0f34edfc9fa345bf53ea4f84ee8b8619ebcf1 Hyungsuk Hong <aanoaa@gmail.com> 1396933964 +0900
  c3e0f34edfc9fa345bf53ea4f84ee8b8619ebcf1 5c4a3a1f93d9385ae5342c3d5987c89e10c26ea9 Yongbin Yu <supermania@gmail.com> 1396879389 +0900
  0000000000000000000000000000000000000000 5c4a3a1f93d9385ae5342c3d5987c89e10c26ea9 Hyungsuk Hong <aanoaa@gmail.com> 1396953462 +0900 Random#0 87c89e1

=cut

has prev_hash => ( is => 'ro', isa => Sha1sum, required => 1 );
has hash      => ( is => 'ro', isa => Sha1sum, required => 1 );
has author    => ( is => 'ro', isa => Str,     required => 1 );
has email     => (
    is       => 'ro',
    isa      => Str,
    required => 1,
    coerce   => sub {
        $_[0] =~ s{(^\<|>$)}{}g;
        $_[0];
    }
);
has timestamp => ( is => 'ro', isa => Datetime, required => 1 );
has parent =>
    ( is => 'rw', isa => Str, coerce => sub { $_[0] // '' }, default => '' );
has group =>
    ( is => 'rw', isa => Str, coerce => sub { $_[0] // '' }, default => '' );

sub BUILDARGS {
    my ( $class, @args ) = @_;
    return {@args} unless @args == 1;

    my $line = shift @args;
    return Evid::Util::log_parse($line);
}

use overload '""' => sub {
    my $self = shift;
    return sprintf(
        "%s %s %s <%s> %s %s %s %s",
        $self->prev_hash,        $self->hash,
        $self->author,           $self->email,
        $self->timestamp->epoch, $self->timestamp->time_zone->name,
        $self->group,            $self->parent,
    );
};

sub object {
    my $self = shift;
    my $hash = $self->hash;
    my ( $dir, $file ) = $hash =~ /^(.{2})(.+)$/;
    my $path = "$Evid::Constants::OBJECT_DIR/$dir/$file";
    return path($path)->touchpath;
}

1;
