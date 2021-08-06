{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled'])) }}
{% set emails_enabled = fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_email_event_enabled']) %}
{% set engagements_enabled = fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_engagement_enabled']) %}

with contacts as (

    select *
    from {% if var('hubspot_contact_merge_audit_enabled', false) %} 
            {{ ref('int_hubspot__contact_merge_adjust') }} 
        {% else %} 
            {{ var('contact') }} 
        {% endif %}

{% if emails_enabled %}

), email_sends as (

    select *
    from {{ ref('hubspot__email_sends') }}

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

{% endif %}

{% if engagements_enabled %}

{% set cte_ref = 'email_joined' if emails_enabled else 'contacts' %}

), engagements as (

    select *
    from {{ ref('int_hubspot__engagement_metrics__by_contact') }}

), engagements_joined as (

    select 
        {{ cte_ref }}.*,
        {% for metric in engagement_metrics() %}
        coalesce(engagements.{{ metric }},0) as {{ metric }} {% if not loop.last %},{% endif %}
        {% endfor %}
    from {{ cte_ref }}
    left join engagements
        using (contact_id)

)

select *
from engagements_joined

{% elif emails_enabled %}

)

select *
from email_joined

{% else %}

)

select *
from contacts

{% endif %}