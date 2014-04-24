use utf8;
package Evid::Schema::Result::SubjectGroup;
$Evid::Schema::Result::SubjectGroup::VERSION = 'v0.0.1';
# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Evid::Schema::Result::SubjectGroup

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<Evid::Schema::Base>

=cut

use base 'Evid::Schema::Base';

=head1 TABLE: C<subject_group>

=cut

__PACKAGE__->table("subject_group");

=head1 ACCESSORS

=head2 subject_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 idx

  data_type: 'integer'
  is_nullable: 0

=head2 timestamp

  data_type: 'text'
  inflate_datetime: 1
  is_nullable: 1
  set_on_create: 1
  set_on_update: 1

=cut

__PACKAGE__->add_columns(
  "subject_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "idx",
  { data_type => "integer", is_nullable => 0 },
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

=item * L</subject_id>

=item * L</group_id>

=item * L</idx>

=back

=cut

__PACKAGE__->set_primary_key("subject_id", "group_id", "idx");

=head1 RELATIONS

=head2 group

Type: belongs_to

Related object: L<Evid::Schema::Result::Group>

=cut

__PACKAGE__->belongs_to(
  "group",
  "Evid::Schema::Result::Group",
  { id => "group_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 subject

Type: belongs_to

Related object: L<Evid::Schema::Result::Subject>

=cut

__PACKAGE__->belongs_to(
  "subject",
  "Evid::Schema::Result::Subject",
  { id => "subject_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-09 16:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dfvucn4fMxHMvCyi2Ca+Vw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
