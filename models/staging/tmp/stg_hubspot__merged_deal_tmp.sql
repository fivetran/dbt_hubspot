{{ config(enabled=(var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true)) and var('hubspot_merged_deal_enabled', False)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='hubspot_sources',
        single_source_name='hubspot',
        single_table_name='merged_deal'
    )
}}
