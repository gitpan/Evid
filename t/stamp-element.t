use lib 't/lib';
use Test::Most tests => 8;
use Test::Evid;
use Mojo::DOM;

use_ok('Evid::Stamp::Element');
my $t = Test::Evid->new;

my $el;

dies_ok { Evid::Stamp::Element->new() } 'requires name';
dies_ok { Evid::Stamp::Element->new( name => 'yolo' ) } 'requires input';
ok(
    $el = Evid::Stamp::Element->new(
        name  => 'yolo',
        input => { type => 'text' }
    ),
    'new'
);
is( "$el", 'yolo#text', 'stringify' );

subtest 'to_html' => sub {
    ok(
        Mojo::DOM->new(
            Evid::Stamp::Element->new(
                name  => 'yolo',
                input => { type => 'text' }
            )->to_html
            )->find('input[type=text]')->size,
        'text - to_html'
    );

    ok(
        Mojo::DOM->new(
            Evid::Stamp::Element->new(
                name  => 'yolo',
                input => { type => 'radio', values => [1, 2, 3] }
            )->to_html
            )->find('input[type=radio]')->size,
        'radio - to_html'
    );

    ok(
        Mojo::DOM->new(
            Evid::Stamp::Element->new(
                name  => 'yolo',
                input => { type => 'checkbox', values => [1, 2, 3] }
            )->to_html
            )->find('input[type=checkbox]')->size,
        'checkbox - to_html'
    );

    my $html = $t->html;
    my $el   = Evid::Stamp::Element->new(
        name  => 'yolo',
        input => { type => 'html', file => "$html" }
    );

    like( $el->to_html, qr/Elective/, 'html - to_html' );
};

subtest 'to_html with data' => sub {
    my $data = { yolo => '1' };
    ok(
        Mojo::DOM->new(
            Evid::Stamp::Element->new(
                name  => 'yolo',
                input => { type => 'text' }
            )->to_html($data)
            )->find('input[type=text][value=1]')->size,
        'text - to_html'
    );

    ok(
        Mojo::DOM->new(
            Evid::Stamp::Element->new(
                name  => 'yolo',
                input => { type => 'radio', values => [1, 2, 3] }
            )->to_html($data)
            )->find(':checked')->size,
        'radio - to_html'
    );

    ok(
        Mojo::DOM->new(
            Evid::Stamp::Element->new(
                name  => 'yolo',
                input => { type => 'checkbox', values => [1, 2, 3] }
            )->to_html($data)
            )->find(':checked')->size,
        'checkbox - to_html'
    );

    my $html = $t->html;
    my $el   = Evid::Stamp::Element->new(
        name  => 'yolo',
        input => { type => 'html', file => "$html" }
    );

    like( $el->to_html( { GPINTRA => 1 } ), qr/checked/, 'html - to_html' );
};

subtest 'validator' => sub {
    my $element = Evid::Stamp::Element->new(
        name      => 'yolo',
        input     => { type => 'text' },
        validator => [
            { or    => [qw/1 2 3 4/] },
            { range => [qw/1 100/] },
            'dateymd',
            { min => 1 },
            { max => 10 },
            'digit'
        ]
    );

    my ( $validator, $err );
    $validator = shift @{ $element->validator };    # or
    ok( !$validator->( 5, \$err ), '`or` - invalid input' );
    ok( $validator->( 4, \$err ), '`or` - valid input' );
    is( $err, '5 is NOT IN 1 or 2 or 3 or 4', '`or` err' );
    $validator = shift @{ $element->validator };    # range
    ok( !$validator->( 1000, \$err ), '`range` - invalid input' );
    is( $err, '1000 is NOT between 1 and 100', 'range err' );
    ok( $validator->( 5, \$err ), '`range` - valid input' );
    $validator = shift @{ $element->validator };    # dateymd
    ok( !$validator->( 'abcde', \$err ), '`dateymd` - invalid input' );
    is(
        $err,
        '<a href="http://en.wikipedia.org/wiki/ISO_8601">ISO8601</a> date and time formats are allow',
        '`dateymd` err'
    );
    ok( $validator->( '2014-01-01', \$err ), '`dateymd` - valid input' );
    $validator = shift @{ $element->validator };    # min
    ok( !$validator->( 0, \$err ), '`min` - invalid input' );
    is( $err, 'min: 1', '`min` err' );
    ok( $validator->( 5, \$err ), '`min` - valid input' );
    $validator = shift @{ $element->validator };    # max
    ok( !$validator->( 1000, \$err ), '`max` - invalid input' );
    is( $err, 'max: 10', '`max` err' );
    ok( $validator->( 5, \$err ), '`max` - valid input' );
    $validator = shift @{ $element->validator };    # digit
    ok( !$validator->( 'abc', \$err ), '`digit` - invalid input' );
    is( $err, 'only permit digit', '`digit` err' );
    ok( $validator->( 3, \$err ), '`digit` - valid input' );
};
