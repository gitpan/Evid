use utf8;
package Evid::Schema::Result::Subject;
$Evid::Schema::Result::Subject::VERSION = 'v0.0.1';
# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Evid::Schema::Result::Subject

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<Evid::Schema::Base>

=cut

use base 'Evid::Schema::Base';

=head1 TABLE: C<subject>

=cut

__PACKAGE__->table("subject");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sitename

  data_type: 'text'
  is_nullable: 1

=head2 idx

  data_type: 'integer'
  is_nullable: 1

=head2 username

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 created_at

  data_type: 'text'
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1

=head2 data

  data_type: 'text'
  is_nullable: 1
  serializer_class: 'JSON'

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sitename",
  { data_type => "text", is_nullable => 1 },
  "idx",
  { data_type => "integer", is_nullable => 1 },
  "username",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "created_at",
  {
    data_type        => "text",
    inflate_datetime => 1,
    is_nullable      => 1,
    set_on_create    => 1,
  },
  "data",
  { data_type => "text", is_nullable => 1, serializer_class => "JSON" },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 scoreboard

Type: might_have

Related object: L<Evid::Schema::Result::Scoreboard>

=cut

__PACKAGE__->might_have(
  "scoreboard",
  "Evid::Schema::Result::Scoreboard",
  { "foreign.subject_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 subject_groups

Type: has_many

Related object: L<Evid::Schema::Result::SubjectGroup>

=cut

__PACKAGE__->has_many(
  "subject_groups",
  "Evid::Schema::Result::SubjectGroup",
  { "foreign.subject_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-10 18:53:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kLTDdIoyXFiCYHrWpSVBmg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
