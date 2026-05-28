{{ config(enabled=var('hubspot_service_enabled', false) and var('hubspot_conversations_enabled', false)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__conversation_message_history_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__conversation_message_history_tmp')),
                staging_columns=get_conversation_message_history_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        _fivetran_active,
        _fivetran_deleted as is_deleted,
        id as message_id,
        thread_id,
        channel_account_id,
        channel_id,
        from_inbox_id,
        to_inbox_id,
        assigned_to,
        assigned_from,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        created_by,
        direction,
        in_reply_to_id,
        new_status,
        rich_text,
        subject,
        text as message_text,
        truncation_status,
        type as message_type,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        client_type,
        status_type
    from macro

)

select *
from fields