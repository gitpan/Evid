package Evid::User;
$Evid::User::VERSION = 'v0.0.1';
use Moo;
use Types::Evid qw/Str ArrayRef Maybe DB_User/;

has username => ( is => 'rw', isa => Str );
has sitename => ( is => 'rw', isa => Str, trigger => 1 );
has privs    => ( is => 'rw', isa => ArrayRef, default => sub { [] } );
has roles    => ( is => 'rw', isa => ArrayRef, default => sub { [] } );
has rs       => ( is => 'rw', isa => Maybe [DB_User], trigger => 1 );

sub _trigger_sitename {
    my ( $self, $name ) = @_;
    return unless $self->rs;

    my $user_site = $self->rs->user_site;
    if ($user_site) {
        $user_site->update( { sitename => $name } );
    }
    else {
        $self->rs->create_related( 'user_site', { sitename => $name } );
    }
}

sub _trigger_rs {
    my ( $self, $rs ) = @_;
    return if $self->username;

    $self->username( $rs->username );
    $self->sitename( $rs->user_site->sitename ) if $rs->user_site;
}

1;
