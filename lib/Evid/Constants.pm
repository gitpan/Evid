package Evid::Constants;
$Evid::Constants::VERSION = 'v0.0.1';
our $STATUS_CREATED  = 'created';
our $STATUS_ENROLLED = 'enrolled';
our $STATUS_REVOKED  = 'revoked';

our %GENDER = ( 1 => 'Male', 2 => 'Female', 3 => 'Unisex' );

our $PAPER_DIR   = $ENV{EVID_PAPER_DIR} || ".paper";    # for test
our $OBJECT_DIR  = "$PAPER_DIR/objects";
our $SUBJECT_DIR = "$PAPER_DIR/subjects";

1;
