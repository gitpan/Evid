use Test::Most tests => 2;
use Mojo::DOM;

use_ok('Evid::Stamp::Element::Validator');
can_ok( 'Evid::Stamp::Element::Validator',
    qw/or range dateymd min max digit/ );
