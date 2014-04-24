use utf8;
package Evid::Schema::Result::Dashboard;
$Evid::Schema::Result::Dashboard::VERSION = 'v0.0.1';
# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Evid::Schema::Result::Dashboard

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<Evid::Schema::Base>

=cut

use base 'Evid::Schema::Base';

=head1 TABLE: C<dashboard>

=cut

__PACKAGE__->table("dashboard");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 site

  data_type: 'text'
  is_nullable: 1

=head2 group

  data_type: 'text'
  is_nullable: 1

=head2 group_idx

  data_type: 'integer'
  is_nullable: 1

=head2 enrolled

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 complete

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "site",
  { data_type => "text", is_nullable => 1 },
  "group",
  { data_type => "text", is_nullable => 1 },
  "group_idx",
  { data_type => "integer", is_nullable => 1 },
  "enrolled",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "complete",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<site_group_group_idx_unique>

=over 4

=item * L</site>

=item * L</group>

=item * L</group_idx>

=back

=cut

__PACKAGE__->add_unique_constraint("site_group_group_idx_unique", ["site", "group", "group_idx"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-09 16:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KgD4uWbRYQDz2PJYzsw8nA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
