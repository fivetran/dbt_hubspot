with contacts as (

    select *
    from {{ var('contact') }}

), email_sends as (

    select *
    from {{ ref('hubspot__email_sends') }}

), engagements as (

    select *
    from {{ ref('int_hubspot__engagement_metrics__by_contact') }}

), email_metrics as (

    select 
        recipient_email_address,
        {% for metric in var('email_metrics') %}
        sum({{ metric }}) as total_{{ metric }},
        count(distinct case when {{ metric }} > 0 then email_send_id end) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from email_sends
    group by 1

), email_joined as (

    select 
        contacts.*,
        {% for metric in var('email_metrics') %}
        coalesce(email_metrics.total_{{ metric }}, 0) as total_{{ metric }},
        coalesce(email_metrics.total_unique_{{ metric }}, 0) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from contacts
    left join email_metrics
        on contacts.email = email_metrics.recipient_email_address

), engagements_joined as (

    select 
        email_joined.*,
        {% for metric in engagement_metrics() %}
        coalesce(engagements.{{ metric }},0) as {{ metric }} {% if not loop.last %},{% endif %}
        {% endfor %}
    from email_joined
    left join engagements
        using (contact_id)

)

select *
from engagements_joined