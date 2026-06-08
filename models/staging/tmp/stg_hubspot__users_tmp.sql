{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_role_enabled'])) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='users'
    )
}}