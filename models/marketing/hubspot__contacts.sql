{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled'])) }}
{% set emails_enabled = fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_email_event_enabled', 'hubspot_email_event_sent_enabled']) %}
{% set engagements_enabled = fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_engagement_enabled','hubspot_engagement_contact_enabled']) %}

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
        count(distinct case when {{ metric }} > 0 then email_send_id end) as total_unique_{{ metric }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from email_sends
    group by 1

), email_joined as (

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

{% set cte_ref = 'engagements_joined' %}

{% elif emails_enabled %}

{% set cte_ref = 'email_joined' %}

{% else %}

{% set cte_ref = 'contacts' %}

{% endif %}

), contact_form_submission as (

    select *
    from {{ var('contact_form_submission') }}

), form as (

    select *
    from {{ var('form') }}

), form_joined as (

    select 
        {{ cte_ref }}.*,
        contact_form_submission.form_id,
        contact_form_submission.occurred_timestamp as latest_form_submission_timestamp,
        form.name as latest_form_name,
        form.form_type as latest_form_type
    from {{ cte_ref }}
    left join (
        select *,
            row_number() over (
                partition by contact_id
                order by occurred_timestamp desc
            ) as row_num
        from contact_form_submission
    ) contact_form_submission
        on {{ cte_ref }}.contact_id = contact_form_submission.contact_id
        and contact_form_submission.row_num = 1
    left join form
        on contact_form_submission.form_id = form.guid
)

select *
from form_joined