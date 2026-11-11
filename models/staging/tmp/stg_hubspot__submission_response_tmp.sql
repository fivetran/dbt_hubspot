{{ config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_contact_form_enabled', true) and var('hubspot_submission_response_enabled', true))) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='submission_response'
    )
}}
