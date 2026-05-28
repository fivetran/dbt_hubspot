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
        _fivetran_deleted as is_deleted,
        id as conversation_thread_id,
        inbox_id,
        associated_contact_id,
        associated_ticket_id,
        original_channel_account_id,
        original_channel_id,
        assigned_to,
        cast(closed_at as {{ dbt.type_timestamp() }}) as closed_at,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(latest_message_received_timestamp as {{ dbt.type_timestamp() }}) as latest_message_received_timestamp,
        cast(latest_message_sent_timestamp as {{ dbt.type_timestamp() }}) as latest_message_sent_timestamp,
        cast(latest_message_timestamp as {{ dbt.type_timestamp() }}) as latest_message_timestamp,
        spam,
        status
    from macro

)

select *
from fields