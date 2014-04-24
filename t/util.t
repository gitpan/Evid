use lib 't/lib';
use Test::Most tests => 5;
use Test::Evid;
use Path::Tiny;
use Evid::Constants;
use_ok('Evid::Util');
my $temp    = Path::Tiny->tempfile;
my $content = '{"foo":"bar","yolo":"wat"}';
my $hash    = 'f84c8b6ab0ed04f4fdf8a32fba19070f92f73aa3';
my $sample
    = '0000000000000000000000000000000000000000 5c4a3a1f93d9385ae5342c3d5987c89e10c26ea9 Hyungsuk Hong <aanoaa@gmail.com> 1396953462 +0900 Random#0 87c89e1';

$temp->spew_utf8($content);
is( Evid::Util::hash($temp),            $hash, 'hash' );
is( Evid::Util::hash_content($content), $hash, 'hash_content' );

my ( $object, $sha1sum ) = Evid::Util::add_content('abcde');
isa_ok( $object, 'Path::Tiny', 'add_content' );

subtest 'log_parse' => sub {
    my $log = Evid::Util::log_parse($sample);
    is( $log->{prev_hash}, '0' x 40, 'prev_hash' );
    is( $log->{hash},   '5c4a3a1f93d9385ae5342c3d5987c89e10c26ea9', 'hash' );
    is( $log->{author}, 'Hyungsuk Hong',                            'author' );
    is( $log->{email},  '<aanoaa@gmail.com>',                       'email' );
    is( $log->{timestamp}->ymd,             '2014-04-08', 'timestamp' );
    is( $log->{timestamp}->time_zone->name, '+0900',      'timezone' );
    is( $log->{parent},                     '87c89e1',    'parent' );
    is( $log->{group},                      'Random#0',   'group' );
};
