package Evid::Util;
$Evid::Util::VERSION = 'v0.0.1';
use Digest::SHA1;
use Path::Tiny;

use Evid::Constants;
use DateTime;

sub hash {
    my $path = shift;
    return unless $path;

    my $file = path($path);
    return unless $file->exists;

    my $content = $file->slurp_utf8;
    return Digest::SHA1->new->add(
        'blob ' . length($content) . "\0" . $content )->hexdigest();
}

sub hash_content {
    my $content = shift;
    return unless $content;
    return Digest::SHA1->new->add(
        'blob ' . length($content) . "\0" . $content )->hexdigest();
}

sub add_content {
    my $content = shift;
    return unless $content;
    my $hash = hash_content($content);
    my ( $dir, $file ) = $hash =~ m/^(.{2})(.+)$/;
    my $object = path("$Evid::Constants::OBJECT_DIR/$dir/$file")->touchpath;
    $object->spew_utf8($content);
    return ( $object, $hash );
}

sub log_parse {
    my $log = shift;

    my @parts     = split( / /, $log );
    my $prev_hash = shift @parts;
    my $hash      = shift @parts;
    my @author;
    my $email;

    while ( my $part = shift @parts ) {
        if ( $part =~ m/^\</ ) {
            $email = $part;
            last;
        }

        push @author, $part;
    }

    my ( $epoch, $timezone, $group, $parent ) = @parts;
    chomp $parent;
    my $dt = DateTime->from_epoch( epoch => $epoch )->set_time_zone($timezone);
    return {
        prev_hash => $prev_hash,
        hash      => $hash,
        author    => join( ' ', @author ),
        email     => $email,
        timestamp => $dt,
        group     => $group,
        parent    => $parent,
    };
}

1;
