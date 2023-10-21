-- depends_on: {{ source('hubspot', 'ticket') }}
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

with calendar as (

    {% if execute %}
    {% set first_date_query %}
    -- start at the first created ticket
        select  min( property_createdate ) as min_date from {{ source('hubspot','ticket') }}
    {% endset %}
    {% set first_date = run_query(first_date_query).columns[0][0]|string %}
    
    {% else %} {% set first_date = "2016-01-01" %}
    {% endif %}

    select * 
    from (
        {{
            dbt_utils.date_spine(
                datepart = "day", 
                start_date =  "cast('" ~ first_date[0:10] ~ "' as date)", 
                end_date = dbt.dateadd("week", 1, dbt.current_timestamp_in_utc_backcompat())
            )   
        }} 
    ) as date_spine

    {% if is_incremental() %}
    where date_day >= (select min(date_day) from {{ this }} )
    {% endif %}

), ticket as (

    select 
        *,
        cast( {{ dbt.date_trunc('day', "case when closed_at is null then " ~ dbt.current_timestamp_backcompat() ~ " else closed_at end") }} as date) as open_until
    from {{ var('ticket') }}

), joined as (

    select 
        cast(calendar.date_day as date) as date_day,
        ticket.ticket_id
    from calendar 
    inner join ticket
        on cast(calendar.date_day as date) >= cast(ticket.created_at as date)
        and cast(calendar.date_day as date) <= cast(ticket.open_until as date) -- add buffer? 

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['date_day','ticket_id']) }} as id
    from joined

)

select *
from surrogate