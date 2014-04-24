use lib 't/lib';
use Test::Most tests => 12;
use Test::Evid;
use DateTime;
use JSON;

use Evid;
use Evid::Stamp;
use Evid::Subject;
use Evid::Constants;

use_ok('Evid::Paper::Log');

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

my $logs = $subject->commit(
    stamp     => $stamp,
    subject   => $subject,
    input     => encode_json( { foo => 'bar' } ),
    email     => 'aanoaa@gmail.com',
    author    => 'Hyungsuk Hong',
    timestamp => DateTime->now->epoch,
    timezone  => '+0900',
);

my $head   = $logs->head;
my $object = $head->object;
isa_ok( $object,          'Path::Tiny' );
isa_ok( $head->timestamp, 'DateTime' );
like( $head->prev_hash, qr/^\w{40}$/, 'prev_hash' );
like( $head->hash,      qr/^\w{40}$/, 'hash' );
is( $head->author,       'Hyungsuk Hong',    'author' );
is( $head->email,        'aanoaa@gmail.com', 'email' );
is( $object->slurp_utf8, '{"foo":"bar"}',    'content' );
like( "$head", qr/^\w{40} \w{40}/, 'stringify' );
is( "$object",
    "$Evid::Constants::OBJECT_DIR/9f/5dd4e3d9fb23a9ab912462d8556122de8f6c96",
    'object path' );

my $log = Evid::Paper::Log->new("$head");
is( "$head", "$log", 'create by log formatted string' );

$log = Evid::Paper::Log->new(
    prev_hash => '0' x 40,
    hash => ( Evid::Util::add_content( encode_json( { foo => 'bar' } ) ) )[-1],
    email     => 'aanoaa@gmail.com',
    author    => 'Hyungsuk Hong',
    timestamp => DateTime->now,
);

ok( $log, 'create by each params' );
