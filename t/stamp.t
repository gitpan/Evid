use lib 't/lib';
use Test::Most tests => 8;
use Test::Evid;
use JSON;
use DateTime;

use Evid::Paper::Log;

use_ok('Evid::Stamp');

my $t = Test::Evid->new;
my $stamp;

my $regex = qr/^13f808b$/;
like( $stamp = Evid::Stamp->new( $t->meta ), $regex, 'hashref' );
like( Evid::Stamp->new( source => $t->meta_yaml ), $regex, 'yaml' );
like( Evid::Stamp->new( source => $t->meta_json ), $regex, 'json' );

my ( $yaml, $elements ) = $t->meta_yaml2;
$stamp = Evid::Stamp->new( source => $yaml );
like( $stamp, $regex, 'external file reference' );
is( $stamp->hierarchy, <<"EOL", 'hierarchy' );
*One#radio
  One-One#checkbox[item 1]
    One-One-One#text[others]
  One-Two#text[item 1]
  *One-Three#text[item 2]
  *One-Four#checkbox[item 3]
Two#textarea
EOL

# TODO: parent-child 노드의 순서에 따라 html 이 만들어지는지 검증($stamp->to_html)
subtest 'to_html' => sub {
    ok( $stamp->to_html, 'to_html' );
    my $log = Evid::Paper::Log->new(
        prev_hash => '0' x 40,
        hash => ( Evid::Util::add_content( encode_json( { Two => 'oops' } ) ) )
            [-1],
        email     => 'aanoaa@gmail.com',
        author    => 'Hyungsuk Hong',
        timestamp => DateTime->now,
    );
    ok( $stamp->to_html($log), 'to_html($log)' );
};

# SPEC
# - `One` 이 입력되지 않았으면 유효하지 않다
#   - `One` 이 "item 2" 일때 `One-Three` 는 필수이다
#   - `One` 이 "item 3" 일때 `One-Four` 는 필수이다
# -----------------------------------------------------
# *One#radio
#   One-One#checkbox[item 1]
#     One-One-One#text[others]
#   One-Two#text[item 1]
#   *One-Three#text[item 2]
#   *One-Four#checkbox[item 3]
# Two#textarea

# TODO: 더 복잡한 구조

subtest 'validation' => sub {
    my ( $input, $complete );
    $complete = $stamp->test( { One => '1' } );
    ok($complete);
    $complete = $stamp->test( { One => '2', 'One-Three' => 'abcde' } );
    ok( !$complete );
    $complete = $stamp->test( { One => '2', 'One-Three' => '2014-01-01' } );
    ok($complete);
    $complete = $stamp->test( { One => '3', 'One-Four' => '1' } );
    ok($complete);
    $complete = $stamp->test( {} );
    ok( !$complete );
    $complete = $stamp->test( { One => '2' } );
    ok( !$complete );
    $complete = $stamp->test( { One => '3' } );
    ok( !$complete );
    $complete = $stamp->test( { One => '1', 'One-Two' => 'abcd' } );
    ok( !$complete );
    $complete = $stamp->test( { One => '1', 'One-Two' => 99 } );
    ok($complete);
};
