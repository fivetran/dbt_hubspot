{{ config(enabled=var('hubspot_property_enabled', True)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__property_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__property_tmp')),
                staging_columns=get_property_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        _fivetran_id,
        _fivetran_synced,
        calculated,
        created_at,
        description,
        field_type,
        group_name,
        hubspot_defined,
        lower(hubspot_object) as hubspot_object, -- should already be lower but just in case
        label as property_label,
        name as property_name,
        type as property_type,
        updated_at
    from macro
    
)

select *
from fields
