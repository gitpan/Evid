use utf8;
package Evid::Schema::Result::Scoreboard;
$Evid::Schema::Result::Scoreboard::VERSION = 'v0.0.1';
# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Evid::Schema::Result::Scoreboard

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<Evid::Schema::Base>

=cut

use base 'Evid::Schema::Base';

=head1 TABLE: C<scoreboard>

=cut

__PACKAGE__->table("scoreboard");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 subject_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 data

  data_type: 'text'
  is_nullable: 1
  serializer_class: 'JSON'

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "subject_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "data",
  { data_type => "text", is_nullable => 1, serializer_class => "JSON" },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<subject_id_unique>

=over 4

=item * L</subject_id>

=back

=cut

__PACKAGE__->add_unique_constraint("subject_id_unique", ["subject_id"]);

=head1 RELATIONS

=head2 subject

Type: belongs_to

Related object: L<Evid::Schema::Result::Subject>

=cut

__PACKAGE__->belongs_to(
  "subject",
  "Evid::Schema::Result::Subject",
  { id => "subject_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-09 16:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F3fosn3i8ygk8l+kiPJfAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
