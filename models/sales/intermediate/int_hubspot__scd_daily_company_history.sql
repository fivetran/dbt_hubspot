{{ config(materialized='table', enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_company_enabled', 'hubspot_company_property_history_enabled'])) }}

{%- set company_columns = adapter.get_columns_in_relation(ref('int_hubspot__pivot_daily_company_history')) -%}

with change_data as (

    select *
    from {{ ref('int_hubspot__pivot_daily_company_history') }}

), set_values as (

    select
        source_relation,
        date_day,
        company_id,
        id

        {% for col in company_columns if col.name|lower not in ['source_relation','date_day','company_id','id'] %}
        , {{ col.name }} as {{ col.name|lower }}
        -- create a batch/partition once a new value is provided
        , sum( case when {{ col.name }} is null then 0 else 1 end) over (partition by company_id {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }}
            order by date_day rows unbounded preceding) as {{ col.name }}_field_partition

        {% endfor %}

    from change_data

), fill_values as (

-- each row of the pivoted table includes company property values if that property was updated on that day
-- we need to backfill to persist values that have been previously updated and are still valid
    select
        source_relation,
        date_day,
        company_id,
        id

        {% for col in company_columns if col.name|lower not in ['source_relation','date_day','company_id','id'] %}

        -- grab the value that started this batch/partition
        , first_value( {{ col.name }} ) over (
            partition by company_id, {{ col.name }}_field_partition {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }}
            order by date_day asc rows between unbounded preceding and current row) as {{ col.name }}

        {% endfor %}

    from set_values

)

select *
from fill_values
