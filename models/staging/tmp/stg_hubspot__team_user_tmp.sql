{{ config(enabled=(var('hubspot_team_enabled', true) and var('hubspot_team_user_enabled', true))) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='team_user'
    )
}}