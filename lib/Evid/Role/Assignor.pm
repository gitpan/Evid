package Evid::Role::Assignor;
$Evid::Role::Assignor::VERSION = 'v0.0.1';
use Moo::Role;
use Types::Evid qw/Evid/;

sub assign {...}

has evid => ( is => 'ro', isa => Evid, required => 1 );

1;
