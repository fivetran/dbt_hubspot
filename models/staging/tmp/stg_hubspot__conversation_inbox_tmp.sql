{{ config(enabled=var('hubspot_conversation_enabled', false)) }}

{{
    hubspot.hubspot_union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='conversation_inbox'
    )
}}
