use strict;
use warnings;
{
    schema_class   => "Evid::Schema",
    connect_info   => { dsn => "dbi:SQLite:dbname=db/evid.db" },
    loader_options => {
        dump_directory            => 'lib',
        naming                    => { ALL => 'v8' },
        skip_load_external        => 1,
        relationships             => 1,
        col_collision_map         => 'column_%s',
        result_base_class         => 'Evid::Schema::Base',
        overwrite_modifications   => 1,
        datetime_undef_if_invalid => 1,
        custom_column_info        => sub {
            my ( $table, $col_name, $col_info ) = @_;
            if ( $col_name eq 'data' ) {
                return { %$col_info, serializer_class => 'JSON' };
            }
            elsif ( $col_name eq 'timestamp' ) {
                return {
                    %$col_info,
                    set_on_create    => 1,
                    set_on_update    => 1,
                    inflate_datetime => 1
                };
            }
            elsif ( $col_name eq 'created_at' ) {
                return {
                    %$col_info,
                    set_on_create    => 1,
                    inflate_datetime => 1
                };
            }
        },
    },
}
