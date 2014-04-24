package Evid::Assignor::Random;
$Evid::Assignor::Random::VERSION = 'v0.0.1';
use Moo;
use Types::Evid qw/Str PathTiny/;

use Path::Tiny;
use JSON;

with 'Evid::Role::Assignor';

has source => (
    is      => 'ro',
    isa     => PathTiny,
    default => sub {'random.txt'},
    coerce  => sub { path(shift) }
);

has json => ( is => 'lazy' );

sub _build_json { path( shift->source . '.json' ) }

sub assign {
    my ( $self, $subject ) = @_;
    return unless ( $subject && $subject->rs );

    my ( $txt, $json ) = ( $self->source, $self->json );

    unless ( $json->exists ) {
        unless ( $txt->exists ) {
            print STDERR "File not found: $txt\n";
            return;
        }

        my @lines = $txt->lines;
        map {chomp} @lines;
        $json->touchpath->spew(
            encode_json( { index => '0', random => [@lines] } ) );
    }

    my $str = $json->slurp;
    my $fh = $json->openw( { locked => 1 } );
    $fh->autoflush(1);

    my $random_data = decode_json($str);
    my $random      = $random_data->{random}[$random_data->{index}++];
    unless ($random) {
        print STDERR "over index\n";
        return;
    }

    print {$fh} encode_json($random_data);

    my $schema = $self->evid->schema;
    ## Transaction BEGIN
    my $guard = $schema->txn_scope_guard;
    my $group
        = $schema->resultset('Group')->find_or_create( { name => 'Random' } );
    my $rs = $subject->rs;
    my $sg = $rs->subject_groups( { group_id => $group->id },
        { order_by => { -desc => 'idx' } } )->next;

    my $idx = $sg ? $sg->idx + 1 : 0;
    $rs->create_related( 'subject_groups',
        { group_id => $group->id, idx => $idx } );
    $guard->commit;
    ## COMMIT

    return $random;
}

1;
