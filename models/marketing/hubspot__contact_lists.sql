{{ config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_contact_list_enabled', true))) }}

with contact_lists as (

    select *
    from {{ ref('stg_hubspot__contact_list') }}

{% if (var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_contact_enabled', true) and var('hubspot_contact_list_member_enabled', true) and var('hubspot_email_event_sent_enabled', true)) %}

), email_metrics as (

    select *
    from {{ ref('int_hubspot__email_metrics__by_contact_list') }}

), joined as (
    {% set email_metrics = adjust_email_metrics('hubspot__email_sends', 'email_metrics') %}
    select 
        contact_lists.*,
        {% for metric in email_metrics %}
        coalesce(email_metrics.total_{{ metric }}, 0) as total_{{ metric }},
        coalesce(email_metrics.total_unique_{{ metric }}, 0) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from contact_lists
    left join email_metrics
        on contact_lists.contact_list_id = email_metrics.contact_list_id
        and contact_lists.source_relation = email_metrics.source_relation

)

select *
from joined

{% else %}

)

select *
from contact_lists

{% endif %}