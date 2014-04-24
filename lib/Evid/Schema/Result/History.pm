use utf8;
package Evid::Schema::Result::History;
$Evid::Schema::Result::History::VERSION = 'v0.0.1';
# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Evid::Schema::Result::History

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<Evid::Schema::Base>

=cut

use base 'Evid::Schema::Base';

=head1 TABLE: C<history>

=cut

__PACKAGE__->table("history");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 sitename

  data_type: 'text'
  is_nullable: 1

=head2 action

  data_type: 'text'
  is_nullable: 1

=head2 link_target

  data_type: 'text'
  is_nullable: 1

=head2 label

  data_type: 'text'
  is_nullable: 1

=head2 timestamp

  data_type: 'text'
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1
  set_on_update: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "sitename",
  { data_type => "text", is_nullable => 1 },
  "action",
  { data_type => "text", is_nullable => 1 },
  "link_target",
  { data_type => "text", is_nullable => 1 },
  "label",
  { data_type => "text", is_nullable => 1 },
  "timestamp",
  {
    data_type        => "text",
    inflate_datetime => 1,
    is_nullable      => 1,
    set_on_create    => 1,
    set_on_update    => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 username

Type: belongs_to

Related object: L<Evid::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "username",
  "Evid::Schema::Result::User",
  { username => "username" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-09 16:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:prMZ768v7jJ1X6k9LjWepA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
