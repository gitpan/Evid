use lib 't/lib';
use Test::Most tests => 7;

use_ok( 'Types::Evid', 'Input');

package InputTest {
    use Moo;
    use Types::Evid -types;

    has input => ( is => 'ro', isa => Input );
    1;
};

subtest 'Input type general creation' => sub {
    throws_ok { InputTest->new( input => {} ) } qr/Argument 'type' required/;

    throws_ok { InputTest->new( input => { type => 'blah' } ) }
    qr/Invalid type argument :/;

    throws_ok { InputTest->new( input => { type => 'none', values => "foo" } ) }
    qr/Argument 'values' is should be reference of Array/;

    ok(
        InputTest->new( input => { type => 'none' } ),
        q/InputTest->new( input => { type => 'none' }/
    );

    ok(
        my $mock =
          InputTest->new( input => { type => 'none', values => ["foobar"] } ),
        q{InputTest->new( input => { type => 'none', values => ["foobar"] } }
    );
    isa_ok( $mock,        'InputTest' );
    isa_ok( $mock->input, 'HASH' );

    ok( InputTest->new( input => { type => 'text' } ),     'text' );
    ok( InputTest->new( input => { type => 'textarea' } ), 'textarea' );
    ok( InputTest->new( input => { type => 'password' } ), 'password' );
};

subtest 'Input type - paragraph' => sub {
    throws_ok { InputTest->new( input => { type => 'paragraph' } ) }
        qr/Argument 'values' is required/;

    ok( InputTest->new( input => { type => 'paragraph', values => ['wat'] } ),
        'paragraph' );
};

subtest 'Input type - image' => sub {
    throws_ok { InputTest->new( input => { type => 'image' } ) }
        qr/Argument 'values' is required/;

    throws_ok { InputTest->new( input => { type => 'image', values => ['abc'] } ) }
        qr/Item of values's type is should be reference of Hash/;

    throws_ok { InputTest->new( input => { type => 'image', values => [{}] } ) }
        qr/Attribute 'src' is required/;

    ok(
        InputTest->new(
            input => { type => 'image', values => [{ src => 'a.png' }] }
        ),
        'image'
    );
};

subtest 'Input type - checkbox' => sub {
    throws_ok { InputTest->new( input => { type => 'checkbox' } ) }
        qr/Argument 'values' is required/;

    ok( InputTest->new( input => { type => 'checkbox', values => ['item'] } ),
        'checkbox' );
};

subtest 'Input type - radio' => sub {
    throws_ok { InputTest->new( input => { type => 'radio' } ) }
        qr/Argument 'values' is required/;

    ok( InputTest->new( input => { type => 'radio', values => ['item'] } ),
        'radio' );
};

subtest 'Input type - html' => sub {
    throws_ok { InputTest->new( input => { type => 'html' } ) }
        qr/Argument 'file' is required/;

    ok( InputTest->new( input => { type => 'html', file => 'oops.html' } ), 'html' );
};
