use lib 't/lib';
use Test::Most tests => 7;
use Test::Evid;
use Path::Tiny;

use Evid::Constants;

use_ok('Evid');
use_ok('Evid::Subject');
use_ok('Evid::Assignor::Random');

my $t = Test::Evid->new;
my ( $db, $config ) = ( $t->db, $t->config );
my ( $evid, $subject );

subtest 'config' => sub {
    is( Evid->new->config->{db}, "db/evid.db", 'default' );
    is( Evid->new( config => "$config" )->config->{db}, "$db", 'arg' );
    $ENV{EVID_CONF} = "$config";
    $evid = Evid->new;
    is( $evid->config->{db}, "$db", 'ENV{EVID_CONF}' );
};

subtest 'enroll' => sub {
    my $user = $evid->authenticate( 'eslee', '4744' );
    $user->sitename('asan');
    $subject = Evid::Subject->new(
        initial     => 'HHS',
        birthdate   => '1982-12-10',
        gender      => 1,
        enrolled_by => $user->username,
    );

    ok( $evid->enroll($subject) && $subject->rs, 'enroll' );
};

subtest 'assign' => sub {
    subtest 'random' => sub {
        my $txt = $t->randomtxt;
        my $random
            = Evid::Assignor::Random->new( evid => $evid, source => "$txt" );

        is( $random->assign($subject), 'yolo', 'random assign' );

        my $group = $evid->schema->resultset('Group')
            ->find_or_create( { name => 'Random' } );

        is(
            $subject->rs->subject_groups( { group_id => $group->id } )->count,
            1,
            'added assigned data to db'
        );
        is( $random->json, $txt . '.json', 'generated progress file path' );
        is( $random->assign($subject), 'wat', 'random assign again' );
        is(
            $subject->rs->subject_groups( { group_id => $group->id } )->count,
            2,
            'added assigned data to db'
        );
        ok( !$random->assign($subject), 'over source' );
    };
};

subtest 'revoke' => sub {
    ok( $evid->revoke($subject) && !$subject->rs, 'revoke' );
};
