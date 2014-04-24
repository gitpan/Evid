use lib 't/lib';
use Test::Most tests => 2;
use Test::Evid;

use_ok('Evid');

my $t = Test::Evid->new;
my ( $db, $config ) = ( $t->db, $t->config );

my $evid = Evid->new( config => "$config" );

subtest 'authenticate' => sub {
    my $user = $evid->authenticate( 'eslee', '4744' );
    ok( $user,        'authenticated' );
    ok( $user->roles, 'roles' );
    ok( $user->privs, 'privs' );
    is( $user->sitename('asan'),        'asan', 'set sitename' );
    is( $user->rs->user_site->sitename, 'asan', 'sitename updated' );
};
