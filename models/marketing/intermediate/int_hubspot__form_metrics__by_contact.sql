{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_form_enabled' ])) }}

with form as (

    select *
    from {{ ref('stg_hubspot__form') }}

), contact_form_submission as (

    select *
    from {{ ref('stg_hubspot__contact_form_submission') }}

{% if var('hubspot_submission_response_enabled', true) %}
), submission_response_by_conversion as (

    select
        source_relation,
        conversion_id,
        {{ fivetran_utils.string_agg("distinct field_name", "', '") }} as fields_responded_to,
        count(*) as total_responses
    from {{ ref('stg_hubspot__submission_response') }}
    group by 1, 2

{% endif %}
), ranked as (
    select
        source_relation,
        contact_id,
        form_id,
        conversion_id,
        occurred_timestamp,
        row_number() over (partition by contact_id {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }} order by occurred_timestamp asc
            ) = 1 as is_first_conversion,
        row_number() over (partition by contact_id {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }} order by occurred_timestamp desc
            ) = 1 as is_most_recent_conversion
    from contact_form_submission

), first_conversion as (
    select
        source_relation,
        contact_id,
        form_id as first_conversion_form_id,
        conversion_id as first_conversion_id,
        occurred_timestamp as first_conversion_date
    from ranked
    where is_first_conversion

), most_recent_conversion as (
    select
        source_relation,
        contact_id,
        form_id as most_recent_conversion_form_id,
        conversion_id as most_recent_conversion_id,
        occurred_timestamp as most_recent_conversion_date
    from ranked
    where is_most_recent_conversion

), aggregated as (
    select
        source_relation,
        contact_id,
        count(*) as total_form_submissions,
        count(distinct form_id) as total_unique_form_submissions
    from contact_form_submission
    group by 1, 2

), joined as (
    select
        aggregated.source_relation,
        aggregated.contact_id,
        aggregated.total_form_submissions,
        aggregated.total_unique_form_submissions,
        first_conversion.first_conversion_form_id,
        first_conversion.first_conversion_date,
        most_recent_conversion.most_recent_conversion_form_id,
        most_recent_conversion.most_recent_conversion_date
        {% if var('hubspot_submission_response_enabled', true) %}
        , first_sub.fields_responded_to as first_conversion_fields_responded_to
        , first_sub.total_responses as first_conversion_total_responses
        , most_recent_sub.fields_responded_to as most_recent_conversion_fields_responded_to
        , most_recent_sub.total_responses as most_recent_conversion_total_responses
        {% endif %}
    from aggregated
    left join first_conversion
        on aggregated.contact_id = first_conversion.contact_id
        and aggregated.source_relation = first_conversion.source_relation
    left join most_recent_conversion
        on aggregated.contact_id = most_recent_conversion.contact_id
        and aggregated.source_relation = most_recent_conversion.source_relation
    {% if var('hubspot_submission_response_enabled', true) %}
    left join submission_response_by_conversion as first_sub
        on first_conversion.first_conversion_id = first_sub.conversion_id
        and first_conversion.source_relation = first_sub.source_relation
    left join submission_response_by_conversion as most_recent_sub
        on most_recent_conversion.most_recent_conversion_id = most_recent_sub.conversion_id
        and most_recent_conversion.source_relation = most_recent_sub.source_relation
    {% endif %}

), final as (
    select
        joined.source_relation,
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
        {% if var('hubspot_submission_response_enabled', true) %}
        , joined.first_conversion_fields_responded_to
        , joined.first_conversion_total_responses
        , joined.most_recent_conversion_fields_responded_to
        , joined.most_recent_conversion_total_responses
        {% endif %}
    from joined
    left join form as first_form
        on joined.first_conversion_form_id = first_form.form_id
        and joined.source_relation = first_form.source_relation
    left join form as most_recent_form
        on joined.most_recent_conversion_form_id = most_recent_form.form_id
        and joined.source_relation = most_recent_form.source_relation
)

select *
from final