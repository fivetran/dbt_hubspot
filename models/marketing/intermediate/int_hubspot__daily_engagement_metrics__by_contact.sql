{{
    config(
        enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_engagement_enabled', 'hubspot_engagement_contact_enabled']),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='id',
        incremental_strategy = 'insert_overwrite' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}

{# Build a list of (model_ref, enabled_var) pairs so we can union only what's enabled #}
{% set engagement_staging_models = [] %}
{% if fivetran_utils.enabled_vars(['hubspot_engagement_call_enabled']) %}
    {% do engagement_staging_models.append('stg_hubspot__engagement_call') %}
{% endif %}
{% if fivetran_utils.enabled_vars(['hubspot_engagement_email_enabled']) %}
    {% do engagement_staging_models.append('stg_hubspot__engagement_email') %}
{% endif %}
{% if fivetran_utils.enabled_vars(['hubspot_engagement_meeting_enabled']) %}
    {% do engagement_staging_models.append('stg_hubspot__engagement_meeting') %}
{% endif %}
{% if fivetran_utils.enabled_vars(['hubspot_engagement_note_enabled']) %}
    {% do engagement_staging_models.append('stg_hubspot__engagement_note') %}
{% endif %}
{% if fivetran_utils.enabled_vars(['hubspot_engagement_task_enabled']) %}
    {% do engagement_staging_models.append('stg_hubspot__engagement_task') %}
{% endif %}

with engagement_contacts as (

    select
        source_relation,
        engagement_id,
        contact_id
    from {{ ref('stg_hubspot__engagement_contact') }}

), all_engagements as (

    {% if engagement_staging_models | length > 0 %}
        {% for model in engagement_staging_models %}
        {% if not loop.first %}union all{% endif %}
        select
            source_relation,
            engagement_id,
            occurred_timestamp,
            engagement_type
        from {{ ref(model) }}
        {% if is_incremental() %}
        where occurred_timestamp >= (select cast(max(date_day) as {{ dbt.type_timestamp() }}) from {{ this }})
        {% endif %}
        {% endfor %}

    {% else %}

        select
            cast(null as {{ dbt.type_string() }}) as source_relation,
            cast(null as {{ dbt.type_int() }}) as engagement_id,
            cast(null as {{ dbt.type_timestamp() }}) as occurred_timestamp,
            cast(null as {{ dbt.type_string() }}) as engagement_type
        where false

    {% endif %}

), joined as (

    select
        engagement_contacts.source_relation,
        engagement_contacts.contact_id,
        cast({{ dbt.date_trunc('day', 'all_engagements.occurred_timestamp') }} as date) as date_day,
        all_engagements.engagement_type
    from all_engagements
    inner join engagement_contacts
        on all_engagements.engagement_id = engagement_contacts.engagement_id
        and all_engagements.source_relation = engagement_contacts.source_relation
    where all_engagements.occurred_timestamp is not null

), aggregated as (

    select
        source_relation,
        contact_id,
        date_day,
        count(case when engagement_type = 'NOTE' then contact_id end) as count_engagement_notes,
        count(case when engagement_type = 'TASK' then contact_id end) as count_engagement_tasks,
        count(case when engagement_type = 'CALL' then contact_id end) as count_engagement_calls,
        count(case when engagement_type = 'MEETING' then contact_id end) as count_engagement_meetings,
        count(case when engagement_type = 'EMAIL' then contact_id end) as count_engagement_emails,
        count(case when engagement_type = 'INCOMING_EMAIL' then contact_id end) as count_engagement_incoming_emails,
        count(case when engagement_type = 'FORWARDED_EMAIL' then contact_id end) as count_engagement_forwarded_emails
    from joined
    group by 1, 2, 3

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'contact_id', 'date_day']) }} as id
    from aggregated

)

select *
from surrogate
