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

{%- set change_data_columns = adapter.get_columns_in_relation(ref('int_hubspot__scd_daily_ticket_history')) -%}

with change_data as (

    select *
    from {{ ref('int_hubspot__scd_daily_ticket_history') }}

    {% if is_incremental() %}
    where valid_from >= (select max(date_day) from {{ this }})

-- If no issue fields have been updated since the last incremental run, the pivoted_daily_history CTE will return no record/rows.
-- When this is the case, we need to grab the most recent day's records from the previously built table so that we can persist 
-- those values into the future.

), most_recent_data as ( 

    select 
        *
    from {{ this }}
    where date_day = (select max(date_day) from {{ this }} )
    {% endif %}

), calendar as (

    select *
    from {{ ref('int_hubspot__ticket_calendar_spine') }}

), joined as (

    select 
        calendar.date_day,
        calendar.ticket_id
        {% if is_incremental() %}    
            {% for col in change_data_columns if col.name|lower not in ['ticket_id','date_day','id'] %} 
            , coalesce(change_data.{{ col.name }}, most_recent_data.{{ col.name }}) as {{ col.name }}
            {% endfor %}
        
        {% else %}
            {% for col in change_data_columns if col.name|lower not in ['ticket_id','date_day','id'] %} 
            , {{ col.name }}
            {% endfor %}
        {% endif %}

    from calendar
    left join change_data
        on calendar.ticket_id = change_data.ticket_id
        and calendar.date_day = change_data.date_day
    
    {% if is_incremental() %}
    left join most_recent_data
        on calendar.ticket_id = most_recent_data.ticket_id
        and calendar.date_day = most_recent_data.date_day
    {% endif %}

), set_values as (

    select 
        date_day,
        ticket_id
        {% for col in change_data_columns if col.name|lower not in ['ticket_id','date_day','id'] %}        
        -- create a batch/partition once a new value is provided
        , sum(case when joined.{{ col.name }} is null then 0 else 1 end) over (
                partition by ticket_id
                order by date_day rows unbounded preceding) as {{ col.name }}_partition
        {% endfor %}

        from joined

), fill_values as (

    select 
        date_day,
        ticket_id

        {% for col in change_data_columns if col.name|lower not in ['ticket_id','date_day','id'] %}
        -- grab the value that started this batch/partition
        , first_value( {{ col.name }} ) over (
            partition by ticket_id, {{ col.name }}_partition 
            order by date_day asc rows between unbounded preceding and current row) as {{ col.name }}
        {% endfor %}

    from set_values

), fix_null_values as (

    select 
        date_day,
        ticket_id 

        {% for col in change_data_columns if col.name|lower not in ['ticket_id','date_day','id'] %} 
        -- we de-nulled the true null values earlier in order to differentiate them from nulls that just needed to be backfilled
        , case when  cast( {{ col.name }} as {{ dbt.type_string() }} ) = 'is_null' then null else {{ col.name }} end as {{ col.name }}
        {% endfor %}

    from fill_values

), surrogate_key as (

    select
        {{ dbt_utils.generate_surrogate_key(['date_day','id']) }} as ticket_day_id,
        *

    from fix_null_values
)

select *
from surrogate_key