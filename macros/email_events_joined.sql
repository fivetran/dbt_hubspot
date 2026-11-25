{% macro email_events_joined(base_model) %}

with base as (

    select *
    from {{ base_model }}

), events as (

    select *
    from {{ ref('stg_hubspot__email_event') }}

{% if var('hubspot_contact_enabled', true) %}
), contacts as (

    select *
    from {{ ref('int_hubspot__contact_merge_adjust') }} 

), contacts_ranked as (

    -- More than one contact can hold the same email address, for example a live contact and a
    -- deleted one. Keep one contact per address so each event joins to a single contact:
    -- a live contact before a deleted one, then the most recently created.
    select
        source_relation,
        contact_id,
        email,
        is_contact_deleted,
        row_number() over (
            partition by source_relation, email
            order by
                case when coalesce(is_contact_deleted, false) then 1 else 0 end,
                case when created_date is null then 1 else 0 end,
                created_date desc,
                contact_id desc
        ) as email_rank
    from contacts
    where email is not null
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
        on base.event_id = events.event_id
        and base.source_relation = events.source_relation

{% if var('hubspot_contact_enabled', true) %}
), contacts_joined as (

    select 
        events_joined.*,
        contacts.contact_id,
        coalesce(contacts.is_contact_deleted, false) as is_contact_deleted
    from events_joined
    left join contacts_ranked as contacts
        on events_joined.recipient_email_address = contacts.email
        and events_joined.source_relation = contacts.source_relation
        and contacts.email_rank = 1

)

select *
from contacts_joined

{% else %}
)

select *
from events_joined

{% endif %}
{% endmacro %}