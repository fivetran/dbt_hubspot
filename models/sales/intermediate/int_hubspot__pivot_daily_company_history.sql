{{
    config(
        enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_company_enabled', 'hubspot_company_property_history_enabled']),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks', 'duckdb'] else ['date_day'],
        unique_key='id',
        incremental_strategy = 'insert_overwrite' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}

{% set company_columns = (['hubspot_owner_id', 'lifecyclestage'] + var('hubspot__company_property_history_columns', [])) | unique | list %}

with daily_history as (

    select *
    from {{ ref('int_hubspot__daily_company_history') }}

    {% if is_incremental() %}
    where date_day >= {{ hubspot.hubspot_lookback(from_date='max(date_day)', datepart='day', interval=var('lookback_window', 3)) }}
    {% endif %}

), pivot_out as (

    select
        source_relation,
        date_day,
        company_id

        {% for col in company_columns -%}
        , max(case when lower(field_name) = '{{ col|lower }}' then new_value end) as {{ dbt_utils.slugify(col) | replace(' ', '_') | lower }}
        {% endfor -%}

    from daily_history

    group by 1,2,3

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation','date_day', 'company_id']) }} as id
    from pivot_out
)

select *
from surrogate
