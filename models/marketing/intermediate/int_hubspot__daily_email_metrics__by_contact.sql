{{
    config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true)))
}}

{# Build a list of (model_ref, event_type) pairs so we can union only what's enabled #}
{% set email_event_models = [] %}
{% do email_event_models.append(('hubspot__email_event_sent', 'SENT')) if var('hubspot_email_event_sent_enabled', true) %}
{% do email_event_models.append(('hubspot__email_event_delivered', 'DELIVERED')) if var('hubspot_email_event_delivered_enabled', true) %}
{% do email_event_models.append(('hubspot__email_event_opens', 'OPEN')) if var('hubspot_email_event_open_enabled', true) %}
{% do email_event_models.append(('hubspot__email_event_clicks', 'CLICK')) if var('hubspot_email_event_click_enabled', true) %}
{% do email_event_models.append(('hubspot__email_event_bounce', 'BOUNCE')) if var('hubspot_email_event_bounce_enabled', true) %}
{% do email_event_models.append(('hubspot__email_event_spam_report', 'SPAM_REPORT')) if var('hubspot_email_event_spam_report_enabled', true) %}

with all_events as (

    {% if email_event_models | length > 0 %}
        {% for model, event_type in email_event_models %}
        {% if not loop.first %}union all{% endif %}
        select
            source_relation,
            contact_id,
            created_timestamp,
            '{{ event_type }}' as event_type,
            cast(null as {{ dbt.type_string() }}) as subscription_status
        from {{ ref(model) }}
        where contact_id is not null
            and created_timestamp is not null
        {% endfor %}

    {% else %}

        select
            cast(null as {{ dbt.type_string() }}) as source_relation,
            cast(null as {{ dbt.type_int() }}) as contact_id,
            cast(null as {{ dbt.type_timestamp() }}) as created_timestamp,
            cast(null as {{ dbt.type_string() }}) as event_type,
            cast(null as {{ dbt.type_string() }}) as subscription_status
        where false

    {% endif %}

    {% if var('hubspot_email_event_status_change_enabled', true) %}
    union all
    select
        source_relation,
        contact_id,
        created_timestamp,
        'STATUS_CHANGE' as event_type,
        subscription_status
    from {{ ref('hubspot__email_event_status_change') }}
    where contact_id is not null
        and created_timestamp is not null
    {% endif %}

), aggregated as (

    select
        source_relation,
        contact_id,
        cast({{ dbt.date_trunc('day', 'created_timestamp') }} as date) as date_day,
        count(case when event_type = 'SENT' then 1 end) as count_emails_sent,
        count(case when event_type = 'DELIVERED' then 1 end) as count_email_deliveries,
        count(case when event_type = 'OPEN' then 1 end) as count_email_opens,
        count(case when event_type = 'CLICK' then 1 end) as count_email_clicks,
        count(case when event_type = 'BOUNCE' then 1 end) as count_email_bounces,
        count(case when event_type = 'SPAM_REPORT' then 1 end) as count_email_spam_reports
        {% if var('hubspot_email_event_status_change_enabled', true) %}
        , count(case when event_type = 'STATUS_CHANGE' and subscription_status = 'UNSUBSCRIBED' then 1 end) as count_email_unsubscribes
        {% endif %}
    from all_events
    group by 1, 2, 3

)

select *
from aggregated
