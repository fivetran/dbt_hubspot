{{
    config(
        enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_deal_property_history_enabled']),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='deal_day_id',
        incremental_strategy = 'insert_overwrite' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}

{%- set change_data_columns = adapter.get_columns_in_relation(ref('int_hubspot__scd_daily_deal_history')) -%}
{% set lookback_date = hubspot.hubspot_lookback(from_date='max(date_day)', datepart='day', interval=var('lookback_window', 3)) if is_incremental() %}
{% set engagements_enabled = fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_engagement_enabled', 'hubspot_engagement_deal_enabled']) %}

with change_data as (

    select *
    from {{ ref('int_hubspot__scd_daily_deal_history') }}

{% if is_incremental() %}
    where date_day >= {{ lookback_date }}

-- If no deal fields have been updated since the last incremental run, the pivoted_daily_history CTE will return no record/rows.
-- When this is the case, we need to grab the most recent day's records from the previously built table so that we can persist
-- those values into the future.

), most_recent_data as (

    select *
    from {{ this }}
    where date_day = (
        select max(date_day)
        from {{ this }}
        where date_day <= {{ lookback_date }}
    )
{% endif %}

), calendar as (

    select *
    from {{ ref('int_hubspot__deal_calendar_spine') }}

    {% if is_incremental() %}
    where date_day >= {{ lookback_date }}
    {% endif %}

), pipeline as (

    select *
    from {{ ref('stg_hubspot__deal_pipeline') }}

), pipeline_stage as (

    select *
    from {{ ref('stg_hubspot__deal_pipeline_stage') }}

{% if var('hubspot_owner_enabled', true) %}
), owner as (

    select *
    from {{ ref('stg_hubspot__owner') }}

{% endif %}

{% if var('hubspot_team_enabled', true) %}
), team as (

    select *
    from {{ ref('stg_hubspot__team') }}

{% endif %}

{% if engagements_enabled %}
), engagement_metrics as (

    select *
    from {{ ref('int_hubspot__daily_engagement_metrics__by_deal') }}

    {% if is_incremental() %}
    where date_day >= {{ lookback_date }}
    {% endif %}

{% endif %}

), joined as (

    select
        calendar.source_relation,
        calendar.date_day,
        calendar.deal_id
        {% if is_incremental() %}
            {% for col in change_data_columns if col.name|lower not in ['source_relation','deal_id','date_day','id'] %}
            , coalesce(change_data.{{ col.name }}, most_recent_data.{{ col.name }}) as {{ col.name }}
            {% endfor %}

        {% else %}
            {% for col in change_data_columns if col.name|lower not in ['source_relation','deal_id','date_day','id'] %}
            , {{ col.name }}
            {% endfor %}
        {% endif %}

    from calendar
    left join change_data
        on calendar.deal_id = change_data.deal_id
        and calendar.date_day = change_data.date_day
        and calendar.source_relation = change_data.source_relation

    {% if is_incremental() %}
    left join most_recent_data
        on calendar.deal_id = most_recent_data.deal_id
        and calendar.date_day = most_recent_data.date_day
        and calendar.source_relation = most_recent_data.source_relation
    {% endif %}

), set_values as (

    select
        source_relation,
        date_day,
        deal_id

        {% for col in change_data_columns if col.name|lower not in ['source_relation','deal_id','date_day','id'] %}
        , {{ col.name }}
        -- create a batch/partition once a new value is provided
        , sum(case when joined.{{ col.name }} is null then 0 else 1 end) over (
                partition by deal_id {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }}
                order by date_day rows unbounded preceding) as {{ col.name }}_partition
        {% endfor %}

    from joined

), fill_values as (

    select
        source_relation,
        date_day,
        deal_id

        {% for col in change_data_columns if col.name|lower not in ['source_relation','deal_id','date_day','id'] %}
        -- grab the value that started this batch/partition
        , first_value( {{ col.name }} ) over (
            partition by deal_id, {{ col.name }}_partition {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }}
            order by date_day asc rows between unbounded preceding and current row) as {{ col.name }}
        {% endfor %}

    from set_values

), fix_null_values as (

    select
        fill_values.source_relation,
        fill_values.date_day,
        fill_values.deal_id,
        pipeline_stage.is_closed as is_deal_closed,
        pipeline.pipeline_label as pipeline_label,
        pipeline_stage.pipeline_stage_label as pipeline_stage_label
        
        {% if var('hubspot_owner_enabled', true) %}
        , owner.full_name as owner_full_name
        , owner.email_address as owner_email_address
        {% endif %}

        {% if var('hubspot_team_enabled', true) %}
        , team.team_name as hubspot_team_name
        {% endif %}

        {% for col in change_data_columns if col.name|lower not in ['source_relation','deal_id','date_day','id'] %}
        -- we de-nulled the true null values earlier in order to differentiate them from nulls that just needed to be backfilled
        , case when cast( fill_values.{{ col.name }} as {{ dbt.type_string() }} ) = 'is_null' then null else fill_values.{{ col.name }} end as {{ col.name }}
        {% endfor %}

        {% if engagements_enabled %}
        , coalesce(engagement_metrics.count_engagement_notes, 0) as count_engagement_notes
        , coalesce(engagement_metrics.count_engagement_tasks, 0) as count_engagement_tasks
        , coalesce(engagement_metrics.count_engagement_calls, 0) as count_engagement_calls
        , coalesce(engagement_metrics.count_engagement_meetings, 0) as count_engagement_meetings
        , coalesce(engagement_metrics.count_engagement_emails, 0) as count_engagement_emails
        , coalesce(engagement_metrics.count_engagement_incoming_emails, 0) as count_engagement_incoming_emails
        , coalesce(engagement_metrics.count_engagement_forwarded_emails, 0) as count_engagement_forwarded_emails
        {% if var('hubspot_engagement_communication_enabled', false) %}
        , coalesce(engagement_metrics.count_engagement_communications, 0) as count_engagement_communications
        {% endif %}
        {% endif %}

    from fill_values

    left join pipeline
        on fill_values.deal_pipeline_id = pipeline.deal_pipeline_id
        and fill_values.source_relation = pipeline.source_relation
    left join pipeline_stage
        on fill_values.pipeline_stage_id = pipeline_stage.deal_pipeline_stage_id
        and fill_values.source_relation = pipeline_stage.source_relation
    
    {% if var('hubspot_owner_enabled', true) %}
    left join owner
        on cast(fill_values.owner_id as {{ dbt.type_string() }}) = cast(owner.owner_id as {{ dbt.type_string() }})
        and fill_values.source_relation = owner.source_relation
    {% endif %}

    {% if var('hubspot_team_enabled', true) %}
    left join team
        on cast(fill_values.hubspot_team_id as {{ dbt.type_string() }}) = cast(team.team_id as {{ dbt.type_string() }})
        and fill_values.source_relation = team.source_relation
    {% endif %}

    {% if engagements_enabled %}
    left join engagement_metrics
        on fill_values.deal_id = engagement_metrics.deal_id
        and fill_values.date_day = engagement_metrics.date_day
        and fill_values.source_relation = engagement_metrics.source_relation
    {% endif %}

), surrogate as (

    select
        {{ dbt_utils.generate_surrogate_key(['date_day','deal_id','source_relation']) }} as deal_day_id,
        *

    from fix_null_values
)

select *
from surrogate
