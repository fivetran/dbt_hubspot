{{ config(enabled=var('hubspot_property_enabled', True)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__property_option_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__property_option_tmp')),
                staging_columns=get_property_option_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        label as property_option_label,
        property_id,
        lower(hubspot_object) as hubspot_object, -- should already be lower but just in case
        name as property_option_name,
        _fivetran_synced,
        display_order,
        hidden,
        value as property_option_value
    from macro
    
)

select *
from fields
