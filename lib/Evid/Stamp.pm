package Evid::Stamp;
$Evid::Stamp::VERSION = 'v0.0.1';
use Moo;
use Types::Evid qw/Str ArrayRef HashRef PathTiny Element Tree/;

use Carp;
use Digest::SHA1 qw(sha1_hex);
use JSON;
use Path::Tiny;
use Tree::Simple;
use Try::Tiny;
use YAML::Syck ();

use Evid::Stamp::Element;

=head1 SYNOPSIS

  my $stamp = Evid::Stamp->new(
    name => 'foo',
    elements => [
      {...},
      {...},
    ]
  );

  or

  my $stamp = Evid::Stamp->new(source => '/path/to/a.json');
  my $stamp = Evid::Stamp->new(source => '/path/to/a.yaml');

  print "$stamp";           # abbr of sha1sum of string yaml like '1a7d90f'
  print $stamp->to_html;

=cut

has name     => ( is => 'rw', isa => Str );
has tree     => ( is => 'rw', isa => Tree );
has elements => ( is => 'rw', isa => ArrayRef [HashRef], trigger => 1, );
has source => (
    is      => 'ro',
    isa     => PathTiny,
    coerce  => sub { path(shift) },
    trigger => 1
);

sub _trigger_elements {
    my ( $self, $arrayref ) = @_;

    my $root = Tree::Simple->new( 'ROOT', Tree::Simple->ROOT );
    $self->tree($root);
    for my $hashref (@$arrayref) {
        my $element = Evid::Stamp::Element->new($hashref);
        my $subtree = Tree::Simple->new($element);
        $root->addChild($subtree);

        for my $stmt ( @{ $hashref->{statements} ||= [] } ) {
            my $cond = $stmt->{if} || $hashref->{input}{values} || [];
            for my $hashref ( @{ $stmt->{elements} } ) {
                $self->build_tree( $hashref, $cond, $subtree );
            }
        }
    }
}

sub build_tree {
    my ( $self, $hashref, $condition, $tree ) = @_;
    my $element
        = Evid::Stamp::Element->new( ( %$hashref, condition => $condition ) );
    my $subtree = Tree::Simple->new($element);
    $tree->addChild($subtree);

    for my $stmt ( @{ $hashref->{statements} ||= [] } ) {
        my $cond = $stmt->{if} || $hashref->{input}{values} || [];
        for my $hashref ( @{ $stmt->{elements} } ) {
            $self->build_tree( $hashref, $cond, $subtree );
        }
    }
}

sub _trigger_source { shift->parse(@_) }

sub parse {
    my ( $self, $source ) = @_;
    return unless $source;

    my ($head) = $source->lines( { count => 1 } );
    my $whole = $source->slurp_utf8;
    my $data;
    if ( $head =~ /^---/ ) {    # yaml
        $data = try { YAML::Syck::Load($whole) }
        catch { confess "Couldn't Load YAML: $_" };
    }
    elsif ( $head =~ /^({|\[)/ ) {    # json
        $data = try { decode_json($whole) }
        catch { confess "Couldn't decode JSON: $_" };
    }
    else {
        confess "Not support MIME type: $source";
    }

    if ( ref( $data->{elements} ) ne 'ARRAY' ) {
        my $elements = path( $data->{elements} );
        confess "File not found: $elements" unless $elements->exists;

        my ($head) = $elements->lines( { count => 1 } );
        if ( $head =~ /^---/ ) {    # yaml
            $data->{elements}
                = try { YAML::Syck::Load( $elements->slurp_utf8 ) }
            catch { confess "Couldn't Load YAML: $_" };
        }
        elsif ( $head =~ /^({|\[)/ ) {    # json
            $data->{elements} = try { decode_json( $elements->slurp_utf8 ) }
            catch { confess "Couldn't decode JSON: $_" };
        }
        else {
            confess "Not support MIME type: $elements";
        }
    }

    $self->name( $data->{name} );
    $self->elements( $data->{elements} );
}

use overload '""' => sub { substr sha1_hex( shift->to_yaml ), 0, 7 };

sub to_yaml {
    my $self = shift;
    return YAML::Syck::Dump(
        { name => $self->name, elements => $self->elements } );
}

sub to_yml { shift->to_yaml(@_) }

sub hierarchy {
    my $self = shift;
    my $out  = '';
    $self->tree->traverse(
        sub {
            my ($tree) = @_;
            my $pad = '  ' x $tree->getDepth();
            $out .= $pad . $tree->getNodeValue() . "\n";
        }
    );
    return $out;
}

sub to_html {
    my ( $self, $log ) = @_;
    my $data = $log ? decode_json( $log->object->slurp_utf8 || '{}' ) : {};
    my @html;
    $self->tree->traverse(
        sub {
            my ($tree) = @_;
            my $pad = '  ' x $tree->getDepth();
            push @html, $pad . "<div>\n";
            $pad .= '  ';
            push @html, $pad . $tree->getNodeValue()->to_html($data);
        },
        sub {
            my ($tree) = @_;
            my $pad = '  ' x $tree->getDepth();
            push @html, $pad . "</div>\n";
        }
    );
    return join '', @html;
}

sub test {
    my ( $self, $data ) = @_;
    return $self->required_test($data) && $self->validator_test($data);
}

sub required_test {
    my ( $self, $data ) = @_;
    my $valid = 1;
    $self->tree->traverse(
        sub {
            my ($tree) = @_;
            my $element = $tree->getNodeValue();
            return unless $valid && $element->required;
            my $parent = $tree->getParent();
            if ( $parent->isRoot ) {
                unless ( $data->{ $element->name } ) {
                    $valid = 0;
                    return;
                }
            }
            else {
                my $pel   = $parent->getNodeValue();
                my @cond  = @{ $element->condition };
                my $value = $pel->input->{values}[$data->{ $pel->name } - 1];
                if ( grep {/$value/} @cond ) {
                    unless ( $data->{ $element->name } ) {
                        $valid = 0;
                        return;
                    }
                }
            }
        }
    );

    return $valid;
}

sub validator_test {
    my ( $self, $data ) = @_;
    my $valid = 1;
    $self->tree->traverse(
        sub {
            my ($tree) = @_;
            my $element = $tree->getNodeValue();
            return unless $valid && defined( $data->{ $element->name } );
            for my $validator ( @{ $element->validator } ) {
                my $err;
                unless ( $validator->( $data->{ $element->name }, \$err ) ) {
                    print STDERR "$err\n";
                    $valid = 0;
                    return;
                }
            }
        }
    );

    return $valid;
}

1;
