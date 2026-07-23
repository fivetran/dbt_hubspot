{{ config(enabled=var('hubspot_marketing_enabled', true) and var('hubspot_marketing_event_enabled', true) and var('hubspot_marketing_event_list_enabled', true)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__marketing_event_list_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__marketing_event_list_tmp')),
                staging_columns=get_marketing_event_list_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
    from base

), fields as (

    select
        source_relation,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        id as marketing_event_list_id,
        marketing_event_id,
        name as marketing_event_list_name,
        created_by_id,
        updated_by_id,
        cast(filters_updated_at as {{ dbt.type_timestamp() }}) as filters_updated_at,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_timestamp,
        processing_status,
        cast(deleted_at as {{ dbt.type_timestamp() }}) as deleted_timestamp,
        list_version,
        object_type_id,
        size,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_timestamp
    from macro

)

select *
from fields
