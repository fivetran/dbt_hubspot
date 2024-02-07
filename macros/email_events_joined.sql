{% macro email_events_joined(base_model) %}

with base as (

    select *
    from {{ base_model }}

), events as (

    select *
    from {{ var('email_event') }}

), contacts as (

    select *
    from {{ ref('int_hubspot__contact_merge_adjust') }} 

), events_joined as (

    select 
        base.*,
        events.created_timestamp,
        events.email_campaign_id,
        events.recipient_email_address,
        events.sent_timestamp as email_send_timestamp,
        events.sent_by_event_id as email_send_id
    from base
    left join events
        on base.event_id = events.event_id 
        and base.source_relation = events.source_relation

), contacts_joined as (

    select 
        events_joined.*,
        contacts.contact_id,
        coalesce(contacts.is_contact_deleted, false) as is_contact_deleted
    from events_joined
    left join contacts
        on events_joined.recipient_email_address = contacts.email
        and events_joined.source_relation = contacts.source_relation

)

select *
from contacts_joined

{% endmacro %}