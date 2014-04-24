use utf8;
package Evid::Schema::Result::User;
$Evid::Schema::Result::User::VERSION = 'v0.0.1';
# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Evid::Schema::Result::User

=cut

use strict;
use warnings;

=head1 BASE CLASS: L<Evid::Schema::Base>

=cut

use base 'Evid::Schema::Base';

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 username

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 1

=head2 timezone

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "username",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 1 },
  "timezone",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->set_primary_key("username");

=head1 RELATIONS

=head2 histories

Type: has_many

Related object: L<Evid::Schema::Result::History>

=cut

__PACKAGE__->has_many(
  "histories",
  "Evid::Schema::Result::History",
  { "foreign.username" => "self.username" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 subjects

Type: has_many

Related object: L<Evid::Schema::Result::Subject>

=cut

__PACKAGE__->has_many(
  "subjects",
  "Evid::Schema::Result::Subject",
  { "foreign.username" => "self.username" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_site

Type: might_have

Related object: L<Evid::Schema::Result::UserSite>

=cut

__PACKAGE__->might_have(
  "user_site",
  "Evid::Schema::Result::UserSite",
  { "foreign.username" => "self.username" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-04-10 18:04:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hCsygWusMTCAe8HF7vQx3g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
