package Evid;
$Evid::VERSION = 'v0.0.1';
use Moo;

use Net::Silex;
use Try::Tiny;

use Evid::Constants;
use Evid::Schema;
use Evid::Subject;
use Evid::User;

=head1 SYNOPSIS

  # evid.conf.pl
  {
    db => 'db/evid.db',
    ...
  }

  my $evid = Evid->new;    # same as `Evid->new(config => 'evid.conf.pl')`

=head1 ENV

=over

=item * C<EVID_CONF>

config file path - F<evid.conf.pl> is default to use.

=back

=head1 ATTRIBUTES

=head2 config

=head2 schema

L<Evid::Schema>

=cut

has config => (
    is      => 'ro',
    coerce  => sub { do shift },
    default => sub { $ENV{EVID_CONF} || 'evid.conf.pl' }
);

has schema => ( is => 'lazy' );

sub _build_schema {
    my $db = shift->config->{db};
    return Evid::Schema->connect(
        {
            dsn            => "dbi:SQLite:dbname=$db",
            quote_char     => q{`},
            sqlite_unicode => 1,
        }
    );
}

=head1 METHODS

=head2 authenticate

=head2 enroll

=head2 revoke

=cut

sub authenticate {
    my ( $self, $username, $password ) = @_;

    unless ( $username && $password ) {
        print STDERR "username and password are required\n";
        return;
    }

    my $silex = try {
        Net::Silex->new( username => $username, password => $password );
    }
    catch {
        print STDERR "Failed to authenticate: $_\n";
        return;
    };

    return unless $silex;

    my $su     = $silex->user($username);
    my $schema = $self->schema;
    my $rs     = $schema->resultset('User')->find_or_create(
        {
            username => $username,
            email    => $su->email,
            timezone => $self->config->{timezone}
        }
    );

    unless ($rs) {
        print STDERR "Not found(created) user: $username\n";
        return;
    }

    return Evid::User->new(
        username => $username,
        privs    => [$su->privs],
        roles    => [$su->roles],
        rs       => $rs
    );
}

sub enroll {
    my ( $self, $subject ) = @_;

    return unless $subject;
    if ( $subject->status eq $Evid::Constants::STATUS_ENROLLED ) {
        print STDERR "$subject already enrolled\n";
        return;
    }

    my $schema   = $self->schema;
    my $data     = $subject->to_hashref;
    my $username = $subject->enrolled_by;

    my $user = $schema->resultset('User')->find( { username => $username } );
    unless ($user) {
        print STDERR "Not found user: $username\n";
        return;
    }

    unless ( $user->user_site ) {
        print STDERR "$username must be set sitename\n";
        return;
    }

    my $sitename = $user->user_site->sitename;
    my $latest
        = $schema->resultset('Subject')->search( { sitename => $sitename },
        { order_by => { -desc => 'id' } } )->next;
    my $idx = $latest ? $latest->idx + 1 : 1;
    my $rs = $self->schema->resultset('Subject')->create(
        {
            username => $username,
            sitename => $sitename,
            idx      => $idx,
            data     => $data
        }
    );
    unless ($rs) {
        print STDERR "Couldn't create a new subject\n";
        return;
    }

    $subject->rs($rs);
    return $subject;
}

sub revoke {
    my ( $self, $subject ) = @_;
    return unless $subject->rs;
    $subject->rs->delete && $subject->rs(undef);
    return 1;
}

1;
