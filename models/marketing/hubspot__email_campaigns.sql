{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled'])) }}


with campaigns as (

    select *
    from {{ ref('stg_hubspot__email_campaign') }}

), email_sends as (

    select *
    from {{ ref('hubspot__email_sends') }}

), email_metrics as (

    select 
        email_campaign_id,
        {% for metric in var('email_metrics') %}
        sum(email_sends.{{ metric }}) as total_{{ metric }},
        count(distinct case when email_sends.{{ metric }} > 0 then email_send_id end) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from email_sends
    group by 1

), joined as (

    select 
        campaigns.*,
        {% for metric in var('email_metrics') %}
        coalesce(email_metrics.total_{{ metric }}, 0) as total_{{ metric }},
        coalesce(email_metrics.total_unique_{{ metric }}, 0) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from campaigns
    left join email_metrics
        on campaigns.email_campaign_id = email_metrics.email_campaign_id

)

select *
from joined