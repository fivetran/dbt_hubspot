{{ config(enabled=var('hubspot_owner_enabled', true)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='owner'
    )
}}
