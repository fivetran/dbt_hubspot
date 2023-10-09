{{
    config(
        enabled=var('hubspot_service_enabled', False),
        materialized='incremental',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='id',
        incremental_strategy = 'merge' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}

{% set ticket_columns = (var('hubspot__ticket_field_history_columns', []) + ['hs_pipeline', 'hs_pipeline_stage'])|unique|list %}

with daily_history as (

    select *
    from {{ ref('int_hubspot__daily_ticket_history') }}

    {% if is_incremental() %}
    where date_day >= (select max(date_day) from {{ this }} )
    {% endif %}

), pivot_out as (

    select 
        date_day, 
        ticket_id

        {% for col in ticket_columns -%}
        , max(case when lower(field_name) = '{{ col|lower }}' then new_value end) as {{ dbt_utils.slugify(col) | replace(' ', '_') | lower }}
        , max(case when lower(field_name) = '{{ col|lower }}' then change_source end) as {{ (dbt_utils.slugify(col) | replace(' ', '_') | lower) ~ '_change_source' }}
        , max(case when lower(field_name) = '{{ col|lower }}' then change_source_id end) as {{ (dbt_utils.slugify(col) | replace(' ', '_') | lower) ~ '_change_source_id' }}
        {% endfor -%}

    from daily_history

    group by 1,2

), surrogate as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['date_day', 'ticket_id']) }} as id
    from pivot_out
)

select *
from daily_history