{% macro email_events_joined(base_model) %}

with base as (

    select *
    from {{ base_model }}

), events as (

    select *
    from {{ var('email_event') }}

), contacts as (

    select *
    from {% if var('hubspot_contact_merge_audit_enabled', false) %} 
            {{ ref('int_hubspot__contact_merge_adjust') }} 
        {% else %} 
            {{ var('contact') }} 
        {% endif %}

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
        using (event_id)

), contacts_joined as (

    select 
        events_joined.*,
        contacts.contact_id
    from events_joined
    left join contacts
        on events_joined.recipient_email_address = contacts.email

)

select *
from contacts_joined

{% endmacro %}