{% set email_metrics = [
    'bounces',
    'clicks',
    'deferrals',
    'deliveries',
    'drops',
    'forwards',
    'opens',
    'prints',
    'spam_reports',
    'unsubscribes'
] %}

with contacts as (

    select *
    from {{ ref('stg_hubspot__contact') }}

), email_sends as (

    select *
    from {{ ref('hubspot__email_sends') }}

), email_metrics as (

    select 
        recipient_email_address,
        {% for metric in email_metrics %}
        sum(email_sends.{{ metric }}) as total_{{ metric }},
        count(distinct case when email_sends.{{ metric }} > 0 then email_send_id end) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from email_sends
    group by 1

), joined as (

    select 
        contacts.*,
        {% for metric in email_metrics %}
        coalesce(email_metrics.total_{{ metric }}, 0) as total_{{ metric }},
        coalesce(email_metrics.total_unique_{{ metric }}, 0) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from contacts
    left join email_metrics
        on contacts.email = email_metrics.recipient_email_address

)

select *
from joined