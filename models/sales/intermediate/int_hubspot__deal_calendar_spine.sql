{{
    config(
        enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_deal_property_history_enabled']),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='id',
        incremental_strategy = 'insert_overwrite' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}
-- depends_on: {{ ref('stg_hubspot__deal') }}

with calendar as (

    {% if execute and flags.WHICH in ('run', 'build') %}
    {% set first_date_query %}
    -- start at the first created deal
        select  min( created_date ) as min_date from {{ ref('stg_hubspot__deal') }}
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

), deal as (

    select
        *,
        cast( {{ dbt.date_trunc('day', "case when closed_date is null then " ~ dbt.current_timestamp_backcompat() ~ " else closed_date end") }} as date) as open_until
    from {{ ref('stg_hubspot__deal') }}
    where not coalesce(is_deal_deleted, false)

), joined as (

    select
        cast(calendar.date_day as date) as date_day,
        deal.deal_id,
        deal.source_relation
    from calendar
    inner join deal
        on cast(calendar.date_day as date) >= cast(deal.created_date as date)
        and cast(calendar.date_day as date) <= {{ dbt.dateadd('day', var('deal_history_extension_days', 30), 'deal.open_until') }}

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['date_day','deal_id','source_relation']) }} as id
    from joined

)

select *
from surrogate
