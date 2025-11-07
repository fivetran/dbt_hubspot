{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled','hubspot_engagement_company_enabled'])) }}

{{
    hubspot.hubspot_union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='engagement_company'
    )
}}
