{{
    config(
        enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_deal_property_history_enabled']),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='id',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        file_format='delta'
    )
}}

-- pipeline_stage_id is added manually
{% set deal_columns = (['deal_pipeline_id', 'amount', 'amount_in_home_currency'] + var('hubspot__deal_property_history_columns', [])) %}
{% do deal_columns.append('owner_id') if var('hubspot_owner_enabled', true) %}
{% do deal_columns.append('hubspot_team_id') if var('hubspot_team_enabled', true) %}
{% set deal_columns = deal_columns | unique | list %}
{% set lookback_date = hubspot.hubspot_lookback(from_date='max(date_day)', datepart='day', interval=var('lookback_window', 3)) if is_incremental() %}

with deal_history as (

    select
        source_relation,
        deal_id,
        field_name,
        new_value,
        change_source,
        change_source_id,
        cast({{ dbt.date_trunc('day', 'valid_from') }} as date) as date_day,
        valid_from,
        valid_to

    from {{ ref('hubspot__deal_history') }}

    where lower(field_name) in ({{ "'" ~ deal_columns | join("', '") ~ "'" }})

    {% if is_incremental() %}
    and cast(valid_from as date) >= {{ lookback_date }}
    {% elif var('hubspot__daily_history_start_date', none) %}
    and cast(valid_from as date) >= cast('{{ var("hubspot__daily_history_start_date") }}' as date)
    {% endif %}

{# Deal stages are not stored in deal_property_history #}
), deal_stages as (

    select
        source_relation,
        deal_id,
        'pipeline_stage_id' as field_name,
        deal_stage_name as new_value,
        source as change_source,
        source_id as change_source_id,
        cast({{ dbt.date_trunc('day', 'date_entered') }} as date) as date_day,
        _fivetran_start as valid_from,
        _fivetran_end as valid_to

    from {{ ref('stg_hubspot__deal_stage') }}

    {% if is_incremental() %}
    where cast(date_entered as date) >= {{ lookback_date }}
    {% elif var('hubspot__daily_history_start_date', none) %}
    where cast(date_entered as date) >= cast('{{ var("hubspot__daily_history_start_date") }}' as date)
    {% endif %}

), combined as (

    select * from deal_history
    union all
    select * from deal_stages

), order_daily_changes as (

    select
        *,
        row_number() over (
            partition by date_day, deal_id, field_name {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }}
            order by valid_from desc
            ) as row_num
    from combined

), extract_latest as (

    select
        source_relation,
        date_day,
        deal_id,
        field_name,
        case when new_value is null then 'is_null' else new_value end as new_value,
        change_source,
        change_source_id,
        valid_from,
        valid_to

    from order_daily_changes
    where row_num = 1

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['field_name','deal_id','date_day','source_relation']) }} as id
    from extract_latest

)

select *
from surrogate
