{{ config(enabled=var('hubspot_service_enabled', false) and var('hubspot_conversation_enabled', false)) }}

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
        assigned_to as assigned_to_actor_id,
        assigned_from as assigned_from_actor_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        created_by as created_by_actor_id,
        case 
            when created_by like 'A-%' then 'AGENT'
            when created_by like 'B-%' then 'BOT'
            when created_by like 'E-%' then 'EMAIL'
            when created_by like 'I-%' then 'INTEGRATION'
            when created_by like 'L-%' then 'BREEZE'  -- customer agent powered by Hubspot's AI called Breeze
            when created_by like 'S-%' then 'SYSTEM'
            when created_by like 'V-%' then 'VISITOR'
            else 'OTHER' end as created_by_actor_type,
        upper(direction) as direction,
        in_reply_to_id,
        new_status,
        rich_text,
        subject,
        text,
        upper(truncation_status) as truncation_status,
        upper(type) as type,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        upper(client_type) as client_type,
        upper(status_type) as status_type,
        row_number() over (partition by id order by _fivetran_end desc) as version_rank
    from macro
    where coalesce(_fivetran_active, true)
        and not coalesce(_fivetran_deleted, false)

)

select *
from fields