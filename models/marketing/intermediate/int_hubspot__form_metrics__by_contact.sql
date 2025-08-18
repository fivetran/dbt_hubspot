{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_form_enabled' ])) }}

with form as (

    select *
    from {{ ref('stg_hubspot__form') }}
    
), contact_form_submission as (

    select *
    from {{ ref('stg_hubspot__contact_form_submission') }}

), ranked as (
    select
        contact_id,
        form_id,
        occurred_timestamp,
        row_number() over (partition by contact_id order by occurred_timestamp asc
            ) = 1 as is_first_conversion,
        row_number() over (partition by contact_id order by occurred_timestamp desc
            ) = 1 as is_most_recent_conversion
    from contact_form_submission

), first_conversion as (
    select
        contact_id,
        form_id as first_conversion_form_id,
        occurred_timestamp as first_conversion_date
    from ranked
    where is_first_conversion

), most_recent_conversion as (
    select
        contact_id,
        form_id as most_recent_conversion_form_id,
        occurred_timestamp as most_recent_conversion_date
    from ranked
    where is_most_recent_conversion

), aggregated as (
    select
        contact_id,
        count(*) as total_form_submissions,
        count(distinct form_id) as total_unique_form_submissions
    from contact_form_submission
    group by 1

), joined as (
    select
        aggregated.contact_id,
        aggregated.total_form_submissions,
        aggregated.total_unique_form_submissions,
        first_conversion.first_conversion_form_id,
        first_conversion.first_conversion_date,
        most_recent_conversion.most_recent_conversion_form_id,
        most_recent_conversion.most_recent_conversion_date
    from aggregated
    left join first_conversion
        on aggregated.contact_id = first_conversion.contact_id
    left join most_recent_conversion
        on aggregated.contact_id = most_recent_conversion.contact_id

), final as (
    select
        joined.contact_id,
        joined.total_form_submissions,
        joined.total_unique_form_submissions,
        joined.first_conversion_form_id,
        joined.first_conversion_date,
        first_form.form_name as first_conversion_form_name,
        first_form.form_type as first_conversion_form_type,
        joined.most_recent_conversion_form_id,
        joined.most_recent_conversion_date,
        most_recent_form.form_name as most_recent_conversion_form_name,
        most_recent_form.form_type as most_recent_conversion_form_type
    from joined
    left join form as first_form
        on joined.first_conversion_form_id = first_form.form_id
    left join form as most_recent_form
        on joined.most_recent_conversion_form_id = most_recent_form.form_id
)

select *
from final