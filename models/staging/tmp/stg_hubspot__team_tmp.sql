{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_team_enabled'])) }}

{{
    hubspot.hubspot_union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='team'
    )
}}