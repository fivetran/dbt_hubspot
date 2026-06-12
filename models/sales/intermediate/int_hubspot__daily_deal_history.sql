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

{% set deal_columns = (['pipeline', 'amount'] + var('hubspot__deal_property_history_columns', [])) | unique | list %}

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
    and valid_from >= (select cast(max(date_day) as {{ dbt.type_timestamp() }}) from {{ this }} )
    {% endif %}

{# Deal stages are not stored in deal_property_history #}
), deal_stages as (

    select
        source_relation,
        deal_id,
        'deal_stage' as field_name,
        deal_stage_name as new_value,
        source as change_source,
        source_id as change_source_id,
        cast({{ dbt.date_trunc('day', 'date_entered') }} as date) as date_day,
        _fivetran_start as valid_from,
        _fivetran_end as valid_to

    from {{ ref('stg_hubspot__deal_stage') }}

    {% if is_incremental() %}
    where date_entered >= (select cast(max(date_day) as {{ dbt.type_timestamp() }}) from {{ this }} )
    {% endif %}

), combined as (

    select * from deal_history
    union all
    select * from deal_stages

), order_daily_changes as (

    select
        *,
        row_number() over (
            partition by date_day, deal_id, field_name {{ hubspot.partition_by_source_relation() }}
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
