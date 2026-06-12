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

{% set deal_columns = (['pipeline', 'deal_stage', 'amount'] + var('hubspot__deal_property_history_columns', [])) | unique | list %}

with daily_history as (

    select *
    from {{ ref('int_hubspot__daily_deal_history') }}

    {% if is_incremental() %}
    where date_day >= (select max(date_day) from {{ this }} )
    {% endif %}

), pivot_out as (

    select
        source_relation,
        date_day,
        deal_id

        {% for col in deal_columns -%}
        , max(case when lower(field_name) = '{{ col|lower }}' then new_value end) as {{ dbt_utils.slugify(col) | replace(' ', '_') | lower }}
        {% endfor -%}

    from daily_history

    group by 1,2,3

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation','date_day', 'deal_id']) }} as id
    from pivot_out
)

select *
from surrogate
