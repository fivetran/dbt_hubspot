{{
    config(
        enabled=var('hubspot_service_enabled', False),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ('spark', 'databricks', 'duckdb') else ['date_day'],
        unique_key='id',
        incremental_strategy = 'insert_overwrite' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}
-- depends_on: {{ ref('stg_hubspot__ticket_tmp') }}

with calendar as (

    {% if execute and flags.WHICH in ('run', 'build') %}
        {% set first_date_query %}
            {% if is_incremental() %}
                select coalesce(max(date_day), cast('2016-01-01' as date)) from {{ this }}
            {% elif var('hubspot__daily_history_start_date', none) %}
                select cast('{{ var("hubspot__daily_history_start_date") }}' as date)
            {% else %}
                select coalesce(min(cast(property_createdate as date)), cast('2016-01-01' as date)) from {{ ref('stg_hubspot__ticket_tmp') }}
            {% endif %}
        {% endset %}
        {% set first_date = dbt_utils.get_single_value(first_date_query) | string %}

    {% else %}
        {% set first_date = "2016-01-01" %}
    {% endif %}

    {% set start_date = "cast('" ~ first_date[0:10] ~ "' as date)" %}

    select *
    from (
        {{
            dbt_utils.date_spine(
                datepart = "day",
                start_date = start_date,
                end_date = dbt.dateadd("day", 1, dbt.current_timestamp_in_utc_backcompat())
            )
        }}
    ) as date_spine

), ticket as (

    select 
        *,
        cast( {{ dbt.date_trunc('day', "case when closed_date is null then " ~ dbt.current_timestamp_backcompat() ~ " else closed_date end") }} as date) as open_until
    from {{ ref('stg_hubspot__ticket') }}
    where not coalesce(is_ticket_deleted, false)

), joined as (

    select
        cast(calendar.date_day as date) as date_day,
        ticket.ticket_id,
        ticket.source_relation
    from calendar
    inner join ticket
        on cast(calendar.date_day as date) >= cast(ticket.created_date as date)
        -- use this variable to extend the ticket's history past its close date (for reporting/data viz purposes :-)
        and cast(calendar.date_day as date) <= {{ dbt.dateadd('day', var('ticket_history_extension_days', 0), 'ticket.open_until') }}

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['date_day','ticket_id','source_relation']) }} as id
    from joined

)

select *
from surrogate