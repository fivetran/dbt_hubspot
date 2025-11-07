{{ config(enabled=var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_communication_enabled', false)) }}

{{
    hubspot.hubspot_union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='engagement_communication'
    )
}}
