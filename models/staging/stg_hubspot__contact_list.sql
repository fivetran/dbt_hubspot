{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_list_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__contact_list_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__contact_list_tmp')),
                staging_columns=get_contact_list_columns()
            )
        }}
    from base

), fields as (

    select
        id as contact_list_id,
        name as contact_list_name,
        created_by_id,
        object_type_id,
        processing_status,
        processing_type,
        list_version,
        filters_updated_at,
        _fivetran_deleted as is_contact_list_deleted,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_timestamp,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_timestamp,
        deleteable as is_deletable, --Deprecated
        dynamic as is_dynamic, --Deprecated
        metadata_error, --Deprecated
        cast(metadata_last_processing_state_change_at as {{ dbt.type_timestamp() }}) as metadata_last_processing_state_change_at, --Deprecated
        cast(metadata_last_size_change_at as {{ dbt.type_timestamp() }}) as metadata_last_size_change_at, --Deprecated
        metadata_processing, --Deprecated
        metadata_size, --Deprecated
        portal_id --Deprecated

    from macro
    
)

select *
from fields