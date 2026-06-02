{{ config(enabled=var('hubspot_service_enabled', false) and var('hubspot_conversations_enabled', false)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__conversation_thread_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__conversation_thread_tmp')),
                staging_columns=get_conversation_thread_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        id as conversation_thread_id,
        inbox_id,
        cast(associated_contact_id as {{ dbt.type_int() }}) as associated_contact_id,
        cast(associated_ticket_id as {{ dbt.type_int() }}) as associated_ticket_id,
        original_channel_account_id,
        original_channel_id,
        assigned_to as assigned_to_actor_id,
        cast(closed_at as {{ dbt.type_timestamp() }}) as closed_at,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(latest_message_timestamp as {{ dbt.type_timestamp() }}) as latest_message_at,
        cast(latest_message_received_timestamp as {{ dbt.type_timestamp() }}) as latest_message_received_at,
        cast(latest_message_sent_timestamp as {{ dbt.type_timestamp() }}) as latest_message_sent_at,
        spam as is_spam,
        status
    from macro
    where not coalesce(_fivetran_deleted, false)
)

select *
from fields