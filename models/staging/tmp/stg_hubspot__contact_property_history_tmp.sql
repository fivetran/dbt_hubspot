{{ config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_contact_property_enabled', true) and var('hubspot_contact_property_history_enabled', true))) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='contact_property_history'
    )
}}
