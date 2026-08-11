{{
    config(
        enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_property_enabled', 'hubspot_contact_property_history_enabled']),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks', 'duckdb'] else ['date_day'],
        unique_key='id',
        incremental_strategy = 'insert_overwrite' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}

{% set contact_columns = (['lifecyclestage', 'hs_predictivecontactscore_v2', 'hubspot_owner_id'] + var('hubspot__contact_property_history_columns', [])) | unique | list %}

with daily_history as (

    select *
    from {{ ref('int_hubspot__daily_contact_history') }}

    {% if is_incremental() %}
    where date_day >= {{ hubspot.hubspot_lookback(from_date='max(date_day)', datepart='day', interval=var('lookback_window', 3)) }}
    {% endif %}

), pivot_out as (

    select
        source_relation,
        date_day,
        contact_id

        {% for col in contact_columns -%}
        , max(case when lower(field_name) = '{{ col|lower }}' then new_value end) as {{ dbt_utils.slugify(col) | replace(' ', '_') | lower }}
        {% endfor -%}

    from daily_history

    group by 1,2,3

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation','date_day', 'contact_id']) }} as id
    from pivot_out
)

select *
from surrogate
