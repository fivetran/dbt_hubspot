{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_company_list_member_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__company_list_member_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__company_list_member_tmp')),
                staging_columns=get_company_list_member_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
    from base

), fields as (

    select
        source_relation,
        _fivetran_deleted as is_company_list_member_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(added_at as {{ dbt.type_timestamp() }}) as added_timestamp,
        company_id,
        company_list_id
    from macro

)

select *
from fields
