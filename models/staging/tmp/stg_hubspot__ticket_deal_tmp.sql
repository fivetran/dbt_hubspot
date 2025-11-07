{{ config(enabled=(var('hubspot_service_enabled', false) and var('hubspot_ticket_deal_enabled', false))) }}

{{
    hubspot.hubspot_union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='ticket_deal'
    )
}}
