{{ config(enabled=var('hubspot_property_enabled', True)) }}

{{
    hubspot.hubspot_union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='property'
    )
}}
