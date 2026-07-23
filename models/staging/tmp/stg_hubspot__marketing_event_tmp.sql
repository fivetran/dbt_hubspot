{{ config(enabled=var('hubspot_marketing_enabled', true) and var('hubspot_marketing_event_enabled', false)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='marketing_event'
    )
}}
