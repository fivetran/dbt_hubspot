{{ config(enabled=var('hubspot_service_enabled', False)) }}

{{
    hubspot.hubspot_union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='ticket_engagement'
    )
}}
