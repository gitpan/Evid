package Evid::Stamp::Element;
$Evid::Stamp::Element::VERSION = 'v0.0.1';
use utf8;

use Moo;
use Types::Evid qw/Str ArrayRef Input Bool ElementName ElementValidator/;

use Data::Section::Simple qw(get_data_section);
use Mojo::DOM;
use Mojo::Template;
use Path::Tiny;

use Evid::Stamp::Element::Validator;

has name       => ( is => 'ro', isa => ElementName, required => 1 );
has input      => ( is => 'ro', isa => Input,       required => 1 );
has label      => ( is => 'ro', isa => Str,         default  => '' );
has unit       => ( is => 'ro', isa => Str,         default  => '' );
has pre_text   => ( is => 'ro', isa => Str,         default  => '' );
has post_text  => ( is => 'ro', isa => Str,         default  => '' );
has definition => ( is => 'ro', isa => Str,         default  => '' );
has help       => ( is => 'ro', isa => Str,         default  => '' );
has required   => ( is => 'ro', isa => Bool,        default  => sub {0} );
has css_class  => ( is => 'ro', isa => ArrayRef,    default  => sub { [] } );
has condition  => ( is => 'ro', isa => ArrayRef,    default  => sub { [] } );
has validator => (
    is     => 'ro',
    isa    => ArrayRef [ElementValidator],
    coerce => sub {
        my $arr = shift;
        my @coderef;
        for my $item (@$arr) {
            my ( $name, $args ) = ref($item) eq 'HASH' ? %$item : ($item);
            unless ( Evid::Stamp::Element::Validator->can($name) ) {
                print STDERR "Undefined validator: $name\n";
                next;
            }
            push @coderef, Evid::Stamp::Element::Validator->$name($args);
        }
        return [@coderef];
    },
    default => sub { [] },
);

use overload '""' => sub {
    my $self   = shift;
    my $name   = $self->name;
    my $type   = $self->input->{type};
    my @cond   = @{ $self->condition };
    my $cond   = @cond ? join( ', ', @cond ) : '';
    my $format = $cond ? "%s#%s[%s]" : "%s#%s%s";
    my $prefix = $self->required ? '*' : '';
    return sprintf $prefix . $format, $name, $type, $cond;
};

sub to_html {
    my ( $self, $data ) = @_;

    if ( $self->input->{type} eq 'html' ) {
        my $file = path( $self->input->{file} );
        unless ( $file->exists ) {
            print STDERR "File not found: $file\n";
            return '';
        }

        my $html = $file->slurp_utf8;
        my $dom  = Mojo::DOM->new($html);

        # input[type=text]
        for my $e ( $dom->find('input[type=text]')->each ) {
            my $name  = $e->attr('name');
            my $value = $data->{$name};

            next unless defined $value;

            $e->attr( value => $value );
        }

        # textarea
        for my $e ( $dom->find('textarea')->each ) {
            my $name  = $e->attr('name');
            my $value = $data->{$name};

            next unless defined $value;

            $e->append_content($value);
        }

        # input[type=radio]
        for my $e ( $dom->find('input[type=radio]')->each ) {
            my $name    = $e->attr('name');
            my $value   = $e->attr('value');
            my $checked = $data->{$name};

            next unless defined $checked;

            $e->attr( checked => 'true' ) if "$value" eq "$checked";
        }

        # input[type=checkbox]
        for my $e ( $dom->find('input[type=checkbox]')->each ) {
            my $name    = $e->attr('name');
            my $value   = $e->attr('value');
            my $checked = $data->{$name};

            next unless defined $checked;

            my @values = ref($checked) eq 'ARRAY' ? @{$checked} : ($checked);

            $e->attr( checked => 'true' ) if "@values" =~ /\b$value\b/;
        }

        return "<div class=\"custom-html\">$dom</div>\n";
    }
    else {
        my $mt       = Mojo::Template->new;
        my $template = get_data_section('horizontal.html.ep');
        return $mt->render( $template, $self, $data );
    }
}

sub template { get_data_section("$_[1].html.ep") }
sub tpl      { shift->template(@_) }

1;

__DATA__

@@ horizontal.html.ep
% my ($el, $data) = @_;
<div class="control-group">
  <div class="control-label<%= $el->required ? ' required' : '' %>">
    %= $el->label || $el->name || '';
    %= $self->render($el->tpl('definition'), $el->definition) if $el->definition;
    %= $self->render($el->tpl('help'), $el->help) if $el->help;
  </div>
  <div class="controls">
    <span class="pre-text"><%= $el->pre_text || '' %></span>
      %= $self->render($el->tpl('input/' . $el->input->{type}), $el, $data)
    <span class="unit"><%= $el->unit || '' %></span>
    <span class="post-text"><%= $el->post_text || '' %></span>
  </div>
</div>

@@ definition.html.ep
% my $definition = shift;
<i class="icon-info-sign" data-toggle="tooltip" title="<%= $definition %>"></i>

@@ help.html.ep
% my $help = shift;
<i class="icon-question-sign" data-toggle="tooltip" title="<%= $help %>"></i>

@@ input/checkbox-image.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $loop  = 0;
% $data->{$el->name} ||= [];
% my @checked_value = ref($data->{$el->name}) eq 'ARRAY' ? @{ $data->{$el->name} } : ($data->{$el->name});
% for my $value (@{ $input->{values} ||= [] }) {
  % ++$loop;
  % my ($src, $alt) = ref($value) eq 'HASH' ? ($value->{src}, $value->{alt}) : ($value, $value);
  <label class="checkbox">
    <input name="<%= $el->name %>" type="checkbox" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= "@checked_value" =~ m/\b$loop\b/ ? ' checked="checked"' : '' %>/>
    <img src="/assets/<%= $src %>" alt="<%= $alt %>"/>
  </label>
% }

@@ input/checkbox-inline.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $loop  = 0;
% $data->{$el->name} ||= [];
% my @checked_value = ref($data->{$el->name}) eq 'ARRAY' ? @{ $data->{$el->name} } : ($data->{$el->name});
% for my $value (@{ $input->{values} ||= [] }) {
  % ++$loop;
  <label class="checkbox inline">
    <input name="<%= $el->name %>" type="checkbox" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= "@checked_value" =~ m/\b$loop\b/ ? ' checked="checked"' : '' %>/> <%= $value %>
  </label>
% }

@@ input/checkbox-other-inline.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $loop  = 0;
% $data->{$el->name} ||= [];
% my @checked_value = ref($data->{$el->name}) eq 'ARRAY' ? @{ $data->{$el->name} } : ($data->{$el->name});
% for my $value (@{ $input->{values} ||= [] }) {
  % ++$loop;
  <label class="checkbox inline">
    <input name="<%= $el->name %>" type="checkbox" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= "@checked_value" =~ m/\b$loop\b/ ? ' checked="checked"' : '' %>/> <%= $value %>
  </label>
% }
  % ++$loop;
  <label class="checkbox inline">
    <input name="<%= $el->name %>" type="checkbox" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= "@checked_value" =~ m/\b$loop\b/ ? ' checked="checked"' : '' %>/> Other
  </label>
  <label class="inline">
    <input name="<%= $el->name %>-other" type="text" value="<%= $data->{$el->name . '-other'} // '' %>"/>
  </label>

@@ input/checkbox-other.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $loop  = 0;
% $data->{$el->name} ||= [];
% my @checked_value = ref($data->{$el->name}) eq 'ARRAY' ? @{ $data->{$el->name} } : ($data->{$el->name});
% for my $value (@{ $input->{values} ||= [] }) {
  % ++$loop;
  <label class="checkbox">
    <input name="<%= $el->name %>" type="checkbox" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= "@checked_value" =~ m/\b$loop\b/ ? ' checked="checked"' : '' %>/> <%= $value %>
  </label>
% }
  % ++$loop;
  <label class="checkbox inline">
    <input name="<%= $el->name %>" type="checkbox" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= "@checked_value" =~ m/\b$loop\b/ ? ' checked="checked"' : '' %>/> Other
  </label>
  <label class="inline">
    <input name="<%= $el->name %>-other" type="text" value="<%= $data->{$el->name . '-other'} // '' %>"/>
  </label>

@@ input/checkbox.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $loop  = 0;
% $data->{$el->name} ||= [];
% my @checked_value = ref($data->{$el->name}) eq 'ARRAY' ? @{ $data->{$el->name} } : ($data->{$el->name});
% for my $value (@{ $input->{values} ||= [] }) {
  % ++$loop;
  <label class="checkbox">
    <input name="<%= $el->name %>" type="checkbox" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= "@checked_value" =~ m/\b$loop\b/ ? ' checked="checked"' : '' %>/> <%= $value %>
  </label>
% }

@@ input/image.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my @values = ref($input->{values}) eq 'ARRAY' ? @{ $input->{values} } : ($input->{values});
% for my $value (@values) {
  <div>
    <img src="/assets/<%= $value->{src} %>" alt="<%= $value->{alt} || '' %>" id="img-<%= $el->name %>" class="<%= join(' ', @{ $el->css_class }) %>"/>
  </div>
% }

@@ input/matrix/checkbox.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
<table class="table">
  <thead>
    <tr>
      <th></th>
      % for my $value (@{ $input->{values} ||= [] }) {
        <th><%= $value %></th>
      % }
    </tr>
  </thead>
  <tbody>
    % my $i = 0;
    % for my $row (@{ $input->{rows} ||= [] }) {
      % ++$i;
      <tr>
        <th><%= $row %></th>
        % my $j = 0;
        % my $key = $el->name . $i;
        % my @checked_value = defined($data->{$key}) ?
        %   ref($data->{$key}) eq 'ARRAY' ?
        %     @{ $data->{$key} } :
        %     ($data->{$key})
        %   : ();
        % for my $value (@{ $input->{values} ||= [] }) {
          % ++$j;
          <td>
            <input name="<%= $el->name %><%= $i %>" type="checkbox" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $j %>"<%= "@checked_value" =~ m/\b$j\b/ ? ' checked="checked"' : '' %>/>
          </td>
        % }
      </tr>
    % }
  </tbody>
</table>

@@ input/matrix/radio.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   for my $i (1 .. @{ $input->{rows} ||= [] }) {
%     $data->{$el->name . $i} //= $default;
%   }
% }
<table class="table">
  <thead>
    <tr>
      <th></th>
      % for my $value (@{ $input->{values} ||= [] }) {
        <th><%= $value %></th>
      % }
    </tr>
  </thead>
  <tbody>
    % my $i = 0;
    % for my $row (@{ $input->{rows} ||= [] }) {
      % ++$i;
      <tr>
        <th><%= $row %></th>
        % my $j = 0;
        % my $checked_value = $data->{$el->name . $i} || 0;
        % for my $value (@{ $input->{values} ||= [] }) {
          % ++$j;
          <td>
            <input name="<%= $el->name %><%= $i %>" type="radio" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $j %>"<%= $checked_value == $j ? ' checked="checked"' : '' %>/>
          </td>
        % }
      </tr>
    % }
  </tbody>
</table>

@@ input/matrix/select.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   for my $i (1 .. @{ $input->{rows} ||= [] }) {
%     $data->{$el->name . $i} //= $default;
%   }
% }
<table class="table">
  <tbody>
    % my $i = 0;
    % for my $row (@{ $input->{rows} ||= [] }) {
      % ++$i;
      <tr>
        <th><%= $row %></th>
        % my $j = 0;
        % my $checked_value = $data->{$el->name . $i} || 0;
        <td>
          <select name="<%= $el->name %><%= $i %>" class="<%= join(' ', @{ $el->css_class }) %>">
            <option value=""></option>
            % for my $value (@{ $input->{values} ||= [] }) {
              % ++$j;
              <option value="<%= $j %>"<%= $checked_value == $j ? ' selected="selected"' : '' %>>
                <%= $value %>
              </option>
            % }
          </select>
        </td>
      </tr>
    % }
  </tbody>
</table>

@@ input/paragraph.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
<div class="<%= join(' ', @{ $el->css_class }) %>">
  % for my $value (@{ $input->{values} ||= [] }) {
    <p><%= $value %></p>
  % }
</div>

@@ input/password.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   $data->{$el->name} //= $default;
% }
<input name="<%= $el->name %>" type="password" id="input-<%= $el->name %>" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $data->{$el->name} || '' %>"/>

@@ input/radio-image.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   $data->{$el->name} //= $default;
% }
% my $loop  = 0;
% my $checked_value = $data->{$el->name} || 0;
% for my $value (@{ $input->{values} ||= [] }) {
  % ++$loop;
  % my ($src, $alt) = ref($value) eq 'HASH' ? ($value->{src}, $value->{alt}) : ($value, $value);
  <label class="radio">
    <input name="<%= $el->name %>" type="radio" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= $checked_value == $loop ? ' checked="checked"' : '' %>/>
    <img src="/assets/<%= $src %>" alt="<%= $alt %>"/>
  </label>
% }

@@ input/radio-inline.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   $data->{$el->name} //= $default;
% }
% my $loop  = 0;
% my $checked_value = $data->{$el->name} || 0;
% for my $value (@{ $input->{values} ||= [] }) {
  % ++$loop;
  <label class="radio inline">
    <input name="<%= $el->name %>" type="radio" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= $checked_value == $loop ? ' checked="checked"' : '' %>/> <%= $value %>
  </label>
% }

@@ input/radio.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   $data->{$el->name} //= $default;
% }
% my $loop  = 0;
% my $checked_value = $data->{$el->name} || 0;
% for my $value (@{ $input->{values} ||= [] }) {
  % ++$loop;
  <label class="radio">
    <input name="<%= $el->name %>" type="radio" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $loop %>"<%= $checked_value == $loop ? ' checked="checked"' : '' %>/> <%= $value %>
  </label>
% }

@@ input/select.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   $data->{$el->name} //= $default;
% }
% my $loop  = 0;
% my $checked_value = $data->{$el->name} || 0;
<select name="<%= $el->name %>" class="<%= join(' ', @{ $el->css_class }) %>">
  <option value=""></option>
  % for my $value (@{ $input->{values} ||= [] }) {
    % ++$loop;
    <option value="<%= $loop %>"<%= $checked_value == $loop ? ' selected="true"' : '' %>>
      <%= $value %>
    </option>
  % }
</select>

@@ input/text.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   $data->{$el->name} //= $default;
% }
<input name="<%= $el->name %>" type="text" id="input-<%= $el->name %>" class="<%= join(' ', @{ $el->css_class }) %>" value="<%= $data->{$el->name} // '' %>"<%= $input->{placeholder} ? " placeholder=\"$input->{placeholder}\"" : '' %><%= $input->{readonly} ? " readonly=\"readonly\"" : '' %>/>

@@ input/textarea.html.ep
% my $el    = shift;
% my $data  = shift;
% my $input = $el->input;
% my $default = $input->{default} // '';
% if ($default) {
%   if (my ($k) = $default =~ /^\s*<<\s*(\w+)\s*>>\s*$/) {
%     $default = $data->{subject}{$k} // '';
%   }
%   $data->{$el->name} //= $default;
% }
<textarea name="<%= $el->name %>" id="textarea-<%= $el->name %>" class="<%= join(' ', @{ $el->css_class }) %>"><%= $data->{$el->name} // '' %></textarea>
