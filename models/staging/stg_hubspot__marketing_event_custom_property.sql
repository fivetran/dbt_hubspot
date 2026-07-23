{{ config(enabled=var('hubspot_marketing_enabled', true) and var('hubspot_marketing_event_enabled', false) and var('hubspot_marketing_event_custom_property_enabled', false)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__marketing_event_custom_property_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__marketing_event_custom_property_tmp')),
                staging_columns=get_marketing_event_custom_property_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
    from base

), fields as (

    select
        source_relation,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        marketing_event_id,
        name as property_name,
        value as property_value
    from macro

)

select *
from fields
