{{
    config(
        enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_property_enabled', 'hubspot_contact_property_history_enabled']),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='id',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        file_format='delta'
    )
}}

{% set contact_columns = (['lifecyclestage', 'hs_predictivecontactscore_v2', 'hubspot_owner_id'] + var('hubspot__contact_property_history_columns', [])) | unique | list %}

with history as (

    select *
    from {{ ref('stg_hubspot__contact_property_history') }}

    where lower(field_name) in ({{ "'" ~ contact_columns | join("', '") ~ "'" }})

    {% if is_incremental() %}
    and cast(change_timestamp as date) >= {{ hubspot.hubspot_lookback(from_date='max(date_day)', datepart='day', interval=var('lookback_window', 3)) }}
    {% endif %}

), windows as (

    select
        source_relation,
        cast({{ dbt.date_trunc('day', 'change_timestamp') }} as date) as date_day,
        contact_id,
        field_name,
        new_value,
        change_source,
        change_source_id,
        change_timestamp as valid_from,
        _fivetran_end as valid_to

    from history

), order_daily_changes as (

    select
        *,
        row_number() over (
            partition by date_day, contact_id, field_name {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }}
            order by valid_from desc
            ) as row_num
    from windows

), extract_latest as (

    select
        source_relation,
        date_day,
        contact_id,
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
        {{ dbt_utils.generate_surrogate_key(['field_name','contact_id','date_day','source_relation']) }} as id
    from extract_latest

)

select *
from surrogate
