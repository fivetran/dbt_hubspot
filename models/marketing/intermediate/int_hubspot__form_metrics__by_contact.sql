{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_form_enabled','hubspot_contact_form_submission_enabled'])) }}

with form as (

    select *
    from {{ var('form') }}
    
), contact_form_submission as (

    select *
    from {{ var('contact_form_submission') }}

), contact_form_metrics as (

    select
        distinct contact_id,
        first_value(form_id) over (
            partition by contact_id
            order by occurred_timestamp asc
        ) as first_conversion_form_id,

        first_value(occurred_timestamp) over (
            partition by contact_id
            order by occurred_timestamp asc
        ) as first_conversion_date,

        first_value(form_id) over (
            partition by contact_id
            order by occurred_timestamp desc
        ) as most_recent_conversion_form_id,

        first_value(occurred_timestamp) over (
            partition by contact_id
            order by occurred_timestamp desc
        ) as most_recent_conversion_date,

        count(*) over (partition by contact_id) as total_form_submissions,
        count(distinct form_id) over (partition by contact_id) as total_unique_form_submissions

    from contact_form_submission

), final as (
    select
        contact_form_metrics.contact_id,
        contact_form_metrics.total_form_submissions,
        contact_form_metrics.total_unique_form_submissions,
        contact_form_metrics.first_conversion_form_id,
        contact_form_metrics.first_conversion_date,
        first_form.form_name as first_conversion_form_name,
        first_form.form_type as first_conversion_form_type,
        contact_form_metrics.most_recent_conversion_form_id,
        contact_form_metrics.most_recent_conversion_date,
        most_recent_form.form_name as most_recent_conversion_form_name,
        most_recent_form.form_type as most_recent_conversion_form_type

    from contact_form_metrics
    left join form as first_form
        on contact_form_metrics.first_conversion_form_id = first_form.form_id
    left join form as most_recent_form
        on contact_form_metrics.most_recent_conversion_form_id = most_recent_form.form_id
)

select *
from final