{{ config(enabled=var('hubspot_service_enabled', false) and var('hubspot_conversations_enabled', false)) }}

with conversation_thread as (
    select *
    from {{ ref('stg_hubspot__conversation_thread') }}
),

conversation_message_history as (
    select *
    from {{ ref('stg_hubspot__conversation_message_history') }}
),

conversation_message_recipient as (
    select *
    from {{ ref('stg_hubspot__conversation_message_recipient') }}
),

conversation_message_sender as (
    select *
    from {{ ref('stg_hubspot__conversation_message_sender') }}
),

conversation_actor as (
    select *
    from {{ ref('stg_hubspot__conversation_actor') }}
),

conversation_channel as (
    select *
    from {{ ref('stg_hubspot__conversation_channel') }}
),

conversation_channel_account as (
    select *
    from {{ ref('stg_hubspot__conversation_channel_account') }}
),

conversation_inbox as (
    select *
    from {{ ref('stg_hubspot__conversation_inbox') }}
),

{% if var('hubspot_service_enabled', False) %}
ticket as (
    select *
    from {{ ref('stg_hubspot__ticket') }}
),
{% endif %}

{% if var('hubspot_marketing_enabled', True) and var('hubspot_contact_enabled', True) %}
contact as (
    select *
    from {{ ref('stg_hubspot__contact') }}
),
{% endif %}

message_history_join as (

    select
        conversation_message_history.thread_id,
        conversation_message_history.source_relation,

        -- Latest message timestamps are already available on the conversation_thread table, so just get first
        min(case when conversation_message_history.type = 'MESSAGE' then conversation_message_history.created_at else '9999-01-01' end) as first_message_at,
        min(case when conversation_message_history.direction = 'INCOMING' and conversation_message_history.type = 'MESSAGE' then conversation_message_history.created_at else '9999-01-01' end) as first_message_received_at,
        min(case when conversation_message_history.direction = 'OUTGOING' and conversation_message_history.type = 'MESSAGE' then conversation_message_history.created_at else '9999-01-01' end) as first_message_sent_at,

        -- Overall message counts
        count(distinct case when conversation_message_history.type = 'MESSAGE' then conversation_message_history.message_id end) total_message_count,
        count(distinct case when conversation_message_history.direction = 'INCOMING' and conversation_message_history.type = 'MESSAGE' then conversation_message_history.message_id end) incoming_message_count,
        count(distinct case when conversation_message_history.direction = 'OUTGOING' and conversation_message_history.type = 'MESSAGE' then conversation_message_history.message_id end) outgoing_message_count,

        -- Message counts by sender type
        count(distinct case when conversation_message_history.direction = 'OUTGOING' and conversation_message_history.type = 'MESSAGE' and coalesce(actor_sender.type, conversation_message_history.created_by_actor_type) = 'AGENT' then conversation_message_history.message_id end) agent_outgoing_message_count,
        count(distinct case when conversation_message_history.direction = 'OUTGOING' and conversation_message_history.type = 'MESSAGE' and coalesce(actor_sender.type, conversation_message_history.created_by_actor_type) = 'BOT' then conversation_message_history.message_id end) bot_outgoing_message_count,
        count(distinct case when conversation_message_history.direction = 'OUTGOING' and conversation_message_history.type = 'MESSAGE' and coalesce(actor_sender.type, conversation_message_history.created_by_actor_type) = 'SYSTEM' then conversation_message_history.message_id end) system_outgoing_message_count,

        count(distinct case when conversation_message_history.direction = 'OUTGOING' and conversation_message_history.type = 'MESSAGE' and coalesce(actor_sender.type, conversation_message_history.created_by_actor_type) = 'AGENT' then conversation_message_history.created_by_actor_id end) agent_author_count,
        count(distinct case when coalesce(actor_sender.type, conversation_message_history.created_by_actor_type) = 'AGENT' then conversation_message_history.created_by_actor_id end) involved_agent_count,
        count(distinct case when conversation_message_history.direction = 'INCOMING' and conversation_message_history.type = 'MESSAGE' and coalesce(actor_sender.type, conversation_message_history.created_by_actor_type) = 'VISITOR' then conversation_message_history.created_by_actor_id end) visitor_author_count,

        count(distinct case when conversation_message_history.direction = 'OUTGOING' and conversation_message_history.type = 'MESSAGE' and actor_recipient.type = 'VISITOR' then actor_recipient.actor_id end) visitor_recipient_count,

        -- Other conversation event counts
        count(distinct case when conversation_message_history.type = 'COMMENT' then conversation_message_history.message_id end) comment_count,
        count(distinct case when conversation_message_history.type = 'THREAD_STATUS_CHANGE' then conversation_message_history.message_id end) thread_status_change_count,
        count(distinct case when conversation_message_history.type = 'ASSIGNMENT' then conversation_message_history.message_id end) assignment_count,
        count(distinct case when conversation_message_history.type = 'ASSIGNMENT' then conversation_message_history.assigned_to_actor_id end) unique_assignee_count,
        
        max(conversation_message_history.type = 'WELCOME_MESSAGE') as has_welcome_message

    from conversation_message_history 

    left join conversation_actor actor_sender
        on conversation_message_history.created_by_actor_id = actor_sender.actor_id
        and conversation_message_history.source_relation = actor_sender.source_relation

    -- Messages can be sent to multiple recipients
    left join conversation_message_recipient
        on conversation_message_history.message_id = conversation_message_recipient.message_id
        and conversation_message_history.thread_id = conversation_message_recipient.thread_id
        and conversation_message_history.source_relation = conversation_message_recipient.source_relation

    left join conversation_actor actor_recipient
        on conversation_message_recipient.actor_id = actor_recipient.actor_id
        and conversation_message_recipient.source_relation = actor_recipient.source_relation

    group by 1,2

),

thread_join as (

    select
        conversation_thread.*,
        conversation_inbox.name as inbox_name,
        conversation_inbox.type as inbox_type,
        conversation_inbox.is_active as is_inbox_active,
        conversation_inbox.is_deleted as is_inbox_deleted,
        conversation_channel.name as channel_name,
        conversation_channel.is_deleted as is_channel_deleted,
        conversation_channel_account.name as channel_account_name,
        conversation_channel_account.delivery_identifier_type as channel_account_delivery_identifier_type,
        conversation_channel_account.delivery_identifier_value as channel_account_delivery_identifier_value,
        conversation_channel_account.is_deleted as is_channel_account_deleted,
        {% if var('hubspot_service_enabled') %}
        ticket.ticket_subject,
        ticket.ticket_content,
        ticket.created_date as ticket_created_date,
        ticket.closed_date as ticket_closed_date,
        ticket.ticket_category,
        ticket.owner_id as ticket_owner_id,
        ticket.is_ticket_deleted,
        {% endif %}
        {% if var('hubspot_marketing_enabled') and var('hubspot_contact_enabled') %}
        contact.email as contact_email,
        contact.first_name as contact_first_name,
        contact.last_name as contact_last_name,
        contact.contact_company,
        contact.is_contact_deleted,
        {% endif %}
        {{ dbt.datediff('message_history_join.first_message_received_at', 'message_history_join.first_message_sent_at', 'second') }} as first_response_time_seconds,
        {{ dbt.datediff('message_history_join.first_message_received_at', 'conversation_thread.closed_at', 'second') }} as resolution_time_seconds,
        message_history_join.first_message_at,
        message_history_join.first_message_received_at,
        message_history_join.first_message_sent_at,
        message_history_join.total_message_count,
        message_history_join.incoming_message_count,
        message_history_join.outgoing_message_count,
        message_history_join.agent_outgoing_message_count,
        message_history_join.bot_outgoing_message_count,
        message_history_join.system_outgoing_message_count,
        message_history_join.comment_count,
        message_history_join.assignment_count,
        message_history_join.thread_status_change_count,
        message_history_join.unique_assignee_count,
        message_history_join.involved_agent_count,
        message_history_join.agent_author_count,
        message_history_join.visitor_author_count,
        message_history_join.visitor_recipient_count,
        message_history_join.has_welcome_message

    from conversation_thread
    left join message_history_join
        on conversation_thread.conversation_thread_id = message_history_join.thread_id
        and conversation_thread.source_relation = message_history_join.source_relation
    left join conversation_channel
        on conversation_thread.original_channel_id = conversation_channel.channel_id
        and conversation_thread.source_relation = conversation_channel.source_relation
    left join conversation_channel_account
        on conversation_thread.original_channel_account_id = conversation_channel_account.channel_account_id
        and conversation_thread.source_relation = conversation_channel_account.source_relation
    left join conversation_inbox
        on conversation_thread.inbox_id = conversation_inbox.inbox_id
        and conversation_thread.source_relation = conversation_inbox.source_relation
    {% if var('hubspot_service_enabled') %}
    left join ticket
        on conversation_thread.associated_ticket_id = ticket.ticket_id
        and conversation_thread.source_relation = ticket.source_relation
    {% endif %}
    {% if var('hubspot_marketing_enabled') and var('hubspot_contact_enabled') %}
    left join contact
        on conversation_thread.associated_contact_id = contact.contact_id
        and conversation_thread.source_relation = contact.source_relation
    {% endif %}
)

select *
from thread_join