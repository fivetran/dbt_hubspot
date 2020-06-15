{% macro email_events_joined(base_model) %}

with base as (

    select *
    from {{ base_model }}

), events as (

    select *
    from {{ var('email_event') }}

), joined as (

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

)

select *
from joined

{% endmacro %}