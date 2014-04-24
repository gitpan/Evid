use lib 't/lib';
use Test::Most tests => 12;
use Test::Evid;
use JSON;

use Evid;
use Evid::Constants;
use Evid::Paper::Log;
use Evid::Stamp;
use Evid::Subject;
use Evid::Util;

use_ok('Evid::Paper::Log::Manager');

my $t = Test::Evid->new;
my ( $db, $config ) = ( $t->db, $t->config );
my $evid = Evid->new( config => "$config" );
my $user    = $evid->authenticate( 'eslee', '4744' );
my $stamp   = Evid::Stamp->new( $t->meta );
my $subject = Evid::Subject->new(
    initial     => 'HHS',
    birthdate   => '1982-12-10',
    gender      => 1,
    enrolled_by => $user->username
);

$user->sitename('asan');
$evid->enroll($subject);

$subject->commit(
    stamp     => $stamp,
    subject   => $subject,
    input     => encode_json( { foo => 'bar' } ),
    email     => 'aanoaa@gmail.com',
    author    => 'Hyungsuk Hong',
    timestamp => DateTime->now->epoch,
    timezone  => '+0900',
);

my $logs
    = Evid::Paper::Log::Manager->new( subject => $subject, stamp => $stamp );

ok( $logs,       'new' );
ok( $logs->head, 'head' );

my $log = Evid::Paper::Log->new(
    prev_hash => '0' x 40,
    hash => ( Evid::Util::add_content( encode_json( { foo => 'bar' } ) ) )[-1],
    email     => 'aanoaa@gmail.com',
    author    => 'Hyungsuk Hong',
    timestamp => DateTime->now,
);

ok( $logs->add($log),    'add' );
ok( $logs->all,          'all' );
ok( $logs->count,        'count' );
ok( $logs->last,         'last' );
ok( $logs->first,        'first' );
ok( $logs->has_next,     'has_next' );
ok( $logs->next,         'next' );
ok( $logs->append($log), 'append' );
ok( "$logs",             'stringify' );
