{{ config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_forward_enabled', true))) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='email_event_forward'
    )
}}
