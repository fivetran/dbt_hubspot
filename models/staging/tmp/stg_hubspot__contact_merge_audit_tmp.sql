{{ config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_contact_merge_audit_enabled', false))) }}

{{
    hubspot.hubspot_union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='contact_merge_audit'
    )
}}