{{ config(enabled=var('hubspot_service_enabled', false) and var('hubspot_conversations_enabled', false)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__conversation_channel_account_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__conversation_channel_account_tmp')),
                staging_columns=get_conversation_channel_account_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        _fivetran_deleted as is_deleted,
        id as channel_account_id,
        channel_id,
        inbox_id,
        active as is_active,
        authorized as is_authorized,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        name as channel_account_name,
        delivery_identifier_type,
        delivery_identifier_value
    from macro

)

select *
from fields
