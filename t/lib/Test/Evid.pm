package Test::Evid;

use JSON;
use Path::Tiny;
use YAML::Tiny;
use DateTime;

BEGIN { $ENV{EVID_PAPER_DIR} = Path::Tiny->tempdir }

use Evid::Paper::Log;
use Evid::Util;

sub new {
    my $class = shift;
    my $self = { db => Path::Tiny->tempfile, config => Path::Tiny->tempfile };
    system("sqlite3 $self->{db} < db/init.sql");
    $self->{config}->spew(<<"EOF");
+{
    db       => '$self->{db}',
    timezone => '+0900'
};
EOF
    return bless $self, $class;
}

sub db     { shift->{db} }
sub config { shift->{config} }

sub randomtxt {
    my $txt = Path::Tiny->tempfile;
    $txt->spew(<<"EOF");
yolo
wat
EOF
    return $txt;
}

sub meta {
    return {
        name     => 'sample',
        elements => [
            {
                name     => 'One',
                label    => 'Radio',
                required => '1',
                input    => {
                    type   => 'radio',
                    values => ['item 1', 'item 2', 'item 3']
                },
                statements => [
                    {
                        if       => ['item 1'],
                        elements => [
                            {
                                name  => 'One-One',
                                input => {
                                    type   => 'checkbox',
                                    values => ['yolo', 'wat', 'others']
                                },
                                statements => [
                                    {
                                        if       => ['others'],
                                        elements => [
                                            {
                                                name  => 'One-One-One',
                                                input => { type => 'text' }
                                            }
                                        ]
                                    }
                                ]
                            },
                            {
                                name      => 'One-Two',
                                input     => { type => 'text' },
                                validator => [{ range => [qw/1 100/] }]
                            }
                        ]
                    },
                    {
                        if       => ['item 2'],
                        elements => [
                            {
                                name      => 'One-Three',
                                label     => 'Text',
                                required  => '1',
                                input     => { type => 'text' },
                                validator => ['dateymd']
                            }
                        ]
                    },
                    {
                        if       => ['item 3'],
                        elements => [
                            {
                                name     => 'One-Four',
                                label    => 'Checkbox',
                                required => '1',
                                input    => {
                                    type   => 'checkbox',
                                    values => ['item 1', 'item 2', 'item 3']
                                },
                            }
                        ]
                    }
                ],
            },
            { name => 'Two', input => { type => 'textarea' } }
        ]
    };
}

sub meta_json {
    my $self = shift;
    my $json = Path::Tiny->tempfile;
    Path::Tiny->tempfile;
    $json->spew_utf8( encode_json( $self->meta ) );
    return $json;
}

sub meta_yaml {
    my $self = shift;
    my $yaml = Path::Tiny->tempfile;
    Path::Tiny->tempfile;
    $yaml->spew_utf8( Dump( $self->meta ) );
    return $yaml;
}

sub meta_yaml2 {
    my $self = shift;
    my $meta = $self->meta;
    delete $meta->{name};
    my $elements = Path::Tiny->tempfile;
    $elements->spew_utf8( Dump( $meta->{elements} ) );
    my $yaml = Path::Tiny->tempfile;
    $yaml->spew_utf8(<<"EOF");
---
name: sample
elements: $elements
EOF
    return ( $yaml, $elements );
}

sub log {
    my ( $self, $log, $overwrite ) = @_;

    $overwrite ||= {};
    if ( $log && ref($log) eq 'HASH' ) {
        $overwrite = $log;
        $log       = undef;
    }

    my %args = (
        prev_hash => $log ? $log->hash : '0' x 40,
        hash =>
            ( Evid::Util::add_content( encode_json( { foo => rand } ) ) )[-1],
        email     => 'aanoaa@gmail.com',
        author    => 'Hyungsuk Hong',
        timestamp => DateTime->now,
        parent    => $log ? $log->parent : '',
        group     => $log ? $log->group : '',
    );

    return Evid::Paper::Log->new( %args, %$overwrite );
}

sub html {
    my $self;
    my $file = Path::Tiny->tempfile;
    $file->spew(<<"EOF");
<table class="table table-striped table-bordered table-condensed">
  <thead>
    <tr>
      <th></th>
      <th>Unfractionated heparin</th>
      <th>
        Low molecular weight heparin
        <i data-original-title="" class="icon-info-sign" data-content="Enoxaparin,Dalteparin,Nadroparin,Danaparoid,Hirudin,Argatroba,Lepibudin and Bivarudin etc."></i>
      </th>
      <th>
        GPⅡbⅢa
        <i data-original-title="" class="icon-info-sign" data-content="Abciximab, Eptifibatide,Tirofiban etc."></i>
      </th>
      <th>Other</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th class="required">Pre-procedure</th>
      <td>
        <label class="radio inline">
          <input name="HEPPPR" value="1" type="radio"> Yes
        </label>
        <label class="radio inline">
          <input name="HEPPPR" value="2" type="radio"> No
        </label>
      </td>
      <td>
        <label class="radio inline">
          <input name="LWHPPR" value="1" type="radio"> Yes
        </label>
        <label class="radio inline">
          <input name="LWHPPR" value="2" type="radio"> No
        </label>
      </td>
      <td>
        <label class="radio inline">
          <input name="GPPPR" value="1" type="radio"> Yes
        </label>
        <label class="radio inline">
          <input name="GPPPR" value="2" type="radio"> No
        </label>
      </td>
      <td>
        <label class="radio inline">
          <input name="OTHPPR" value="1" type="radio"> Yes
        </label>
        <label class="radio inline">
          <input name="OTHPPR" value="2" type="radio"> No
        </label>
      </td>
    </tr>
    <tr>
      <th class="required">Intra-procedure</th>
      <td>
        <label class="radio inline">
          <input name="HEPINTRA" value="1" type="radio"> Yes
        </label>
        <label class="radio inline">
          <input name="HEPINTRA" value="2" type="radio"> No
        </label>
      </td>
      <td>
        <label class="radio inline">
          <input name="LWHINTRA" value="1" type="radio"> Yes
        </label>
        <label class="radio inline">
          <input name="LWHINTRA" value="2" type="radio"> No
        </label>
      </td>
      <td>
        <label class="radio inline">
          <input name="GPINTRA" value="1" type="radio"> Yes
        </label>
        <label class="radio inline">
          <input name="GPINTRA" value="2" type="radio"> No
        </label>
      </td>
      <td>
        <label class="radio inline">
          <input name="OTHINTRA" value="1" type="radio"> Yes
        </label>
        <label class="radio inline">
          <input name="OTHINTRA" value="2" type="radio"> No
        </label>
      </td>
    </tr>
    <tr>
      <th>Administration</th>
      <td>
        <textarea name="tarea"></textarea>
      </td>
      <td>
        <input type="checkbox" name="input-c1" value="1"> a
        <input type="checkbox" name="input-c1" value="2"> b
        <input type="checkbox" name="input-c1" value="3"> c
      </td>
      <td>
        <label class="radio inline">
          <input name="GPADMTI" value="1" type="radio"> Elective
        </label>
        <label class="radio inline">
          <input name="GPADMTI" value="2" type="radio"> Bailout
        </label>
      </td>
      <td></td>
    </tr>
    <tr>
      <th>Type</th>
      <td></td>
      <td></td>
      <td>
        <label class="radio inline">
          <input name="GPADMTY" value="1" type="radio"> Abciximab
        </label>
        <br>
        <label class="radio inline">
          <input name="GPADMTY" value="2" type="radio"> Eptifibatide
        </label>
        <br>
        <label class="radio inline">
          <input name="GPADMTY" value="3" type="radio"> Tirofiban
        </label>
      </td>
      <td>
        <label>
          Drug name <input name="OTHDRNAM" value="" type="text">
        </label>
      </td>
    </tr>
  </tbody>
</table>
EOF
    return $file;
}

1;
