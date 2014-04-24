package Dummy::Subject;

sub new { bless {}, shift }

# sub data   { shift || {} }
# sub update { shift || {} }

# stringification
use overload '""' => sub {
    "Subject";
};

1;
