{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_company_list_member_enabled'])) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='company_list_member'
    )
}}
