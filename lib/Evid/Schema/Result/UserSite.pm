use utf8;
package Evid::Schema::Result::UserSite;
$Evid::Schema::Result::UserSite::VERSION = 'v0.0.1';
# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Evid::Schema::Result::UserSite

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<Evid::Schema::Base>

=cut

use base 'Evid::Schema::Base';

=head1 TABLE: C<user_site>

=cut

__PACKAGE__->table("user_site");

=head1 ACCESSORS

=head2 username

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 sitename

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "username",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "sitename",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</username>

=item * L</sitename>

=back

=cut

__PACKAGE__->set_primary_key("username", "sitename");

=head1 UNIQUE CONSTRAINTS

=head2 C<username_unique>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username_unique", ["username"]);

=head1 RELATIONS

=head2 username

Type: belongs_to

Related object: L<Evid::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "username",
  "Evid::Schema::Result::User",
  { username => "username" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-09 16:27:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4l5qPBbR20Gvms7xKsaaLA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
