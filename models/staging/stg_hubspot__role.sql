{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_role_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__role_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__role_tmp')),
                staging_columns=get_role_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        id as role_id,
        name as role_name,
        requires_billing_write,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from macro
)

select *
from fields