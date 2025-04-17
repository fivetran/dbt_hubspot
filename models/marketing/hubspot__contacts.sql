{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled'])) }}
{% set emails_enabled = fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_email_event_enabled', 'hubspot_email_event_sent_enabled']) %}
{% set engagements_enabled = fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_engagement_enabled','hubspot_engagement_contact_enabled']) %}
{% set forms_enabled = fivetran_utils.enabled_vars(['hubspot_contact_form_enabled']) %}

{% set cte_ref = 'contacts' %}
with contacts as (

    select *
    from {{ ref('int_hubspot__contact_merge_adjust') }} 

{% if emails_enabled %}

), email_sends as (

    select *
    from {{ ref('hubspot__email_sends') }}

), email_metrics as (
    {% set email_metrics = adjust_email_metrics('hubspot__email_sends', 'email_metrics') %}
    select 
        recipient_email_address,
        {% for metric in email_metrics %}
        sum({{ metric }}) as total_{{ metric }},
        count(distinct case when {{ metric }} > 0 then email_send_id end)
            as total_unique_{{ metric }}{{ ',' if not loop.last }}
        {% endfor %}
    from email_sends
    group by 1

), email_joined as (

    select 
        contacts.*,
        {% for metric in email_metrics %}
        coalesce(email_metrics.total_{{ metric }}, 0) as total_{{ metric }},
        coalesce(email_metrics.total_unique_{{ metric }}, 0)
            as total_unique_{{ metric }}{{ ',' if not loop.last }}
        {% endfor %}
    from contacts
    left join email_metrics
        on contacts.email = email_metrics.recipient_email_address

{% set cte_ref = 'email_joined' %}
{% endif %}

{% if engagements_enabled %}
), engagements as (

    select *
    from {{ ref('int_hubspot__engagement_metrics__by_contact') }}

), engagements_joined as (

    select 
        {{ cte_ref }}.*,
        {% for metric in engagement_metrics() %}
        coalesce(engagements.{{ metric }},0) as {{ metric }}{{ ',' if not loop.last }}
        {% endfor %}
    from {{ cte_ref }}
    left join engagements
        on {{ cte_ref }}.contact_id = engagements.contact_id

{% set cte_ref = 'engagements_joined' %}
{% endif %}

{% if forms_enabled %}
), conversions as (

    select *
    from {{ ref('int_hubspot__form_metrics__by_contact') }}

), conversions_joined as (

    select 
        {{ cte_ref }}.*,
        {% for first_or_last in ['first_conversion', 'most_recent_conversion']%}
            {% for metric in ['form_id', 'date', 'form_name', 'form_type'] %}
                conversions.{{first_or_last}}_{{ metric }},
            {% endfor %}
        {% endfor %}
        conversions.total_form_submissions,
        conversions.total_unique_form_submissions
    from {{ cte_ref }}
    left join conversions
        on {{ cte_ref }}.contact_id = conversions.contact_id

{% set cte_ref = 'conversions_joined' %}
{% endif %}
)

select *
from {{ cte_ref }}