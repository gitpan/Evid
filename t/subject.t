use lib 't/lib';
use Test::Most tests => 7;
use Test::Evid;
use Path::Tiny;

use Evid::Constants;
use Evid::Stamp;
use DateTime;

use_ok('Evid');
use_ok('Evid::Subject');
use_ok('Evid::Assignor::Random');

my $t = Test::Evid->new;
my ( $db, $config ) = ( $t->db, $t->config );

my $evid = Evid->new( config => "$config" );
my $subject;

subtest 'object' => sub {
    $subject = Evid::Subject->new(
        initial     => 'HHS',
        birthdate   => '1982-12-10',
        gender      => 1,
        enrolled_by => 'eslee',
    );

    is(
        $subject->status,
        $Evid::Constants::STATUS_CREATED,
        "$subject has been created"
    );
    is( "$subject", 'HHS(Male)<1982-12-10>#eslee', 'stringify' );
    is( $subject->serial, undef, 'serial' );
    is_deeply( $subject->to_hashref,
        { initial => 'HHS', birthdate => '1982-12-10', gender => 1 },
        'to_hashref' );
};

subtest 'rs' => sub {
    my $user = $evid->authenticate( 'eslee', '4744' );
    $user->sitename('asan');
    $evid->enroll($subject);
    is(
        $subject->status,
        $Evid::Constants::STATUS_ENROLLED,
        "status changed by enroll action"
    );

    is( $subject->serial, 'ASAN-00001',     'serial' );
    is( "$subject",       $subject->serial, 'stringify - enrolled subject' );
    my $s = Evid::Subject->new( rs => $subject->rs );
    is( $s->initial,     'HHS',        'retrieved data from `resultset`' );
    is( $s->birthdate,   '1982-12-10', 'retrieved data from `resultset`' );
    is( $s->gender,      1,            'retrieved data from `resultset`' );
    is( $s->enrolled_by, 'eslee',      'retrieved data from `resultset`' );

    my $txt = $t->randomtxt;
    my $random
        = Evid::Assignor::Random->new( evid => $evid, source => "$txt" );
    ok( !$subject->groups,         'method groups before assigned' );
    ok( $random->assign($subject), 'assign' );
    is_deeply( $subject->groups, { Random => [0] }, 'method groups' );

    ok( $evid->revoke($subject), 'revoke' );
    is(
        $subject->status,
        $Evid::Constants::STATUS_REVOKED,
        'status changed by revoke action'
    );
    ok( !$random->assign($subject), 'fail to assign revoked subject' );
};

subtest 'logs' => sub {
    can_ok( $subject, 'logs' );
    $evid->enroll($subject);
    my $stamp = Evid::Stamp->new( $t->meta );
    my $logs  = $subject->logs($stamp);
    isa_ok( $logs, 'Evid::Paper::Log::Manager' );

    # TODO: log search by group, parent, author, ...
};

subtest 'commit' => sub {
    my $stamp = Evid::Stamp->new( $t->meta );
    my %args  = (
        stamp     => $stamp,
        group     => '',
        parent    => '',
        input     => {},
        timestamp => DateTime->now->epoch,
        timezone  => '+0900',
        email     => 'aanoaa@gmail.com',
        author    => 'Hyungsuk Hong',
    );
    my $log = $subject->commit(%args);
    isa_ok( $log, 'Evid::Paper::Log::Manager' );

    # TODO: group & parent test
};
