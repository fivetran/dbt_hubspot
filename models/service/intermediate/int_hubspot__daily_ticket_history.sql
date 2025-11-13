{{
    config(
        enabled=var('hubspot_service_enabled', False),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='id',
        incremental_strategy='insert_overwrite' if target.type in ('bigquery', 'spark', 'databricks') else 'delete+insert',
        file_format='delta'
    )
}}

with history as (

    select *
    from {{ ref('stg_hubspot__ticket_property_history') }}

    -- should we include an option pivot out ALL properties? in the same vein as our passthrough-all-columns var
    where lower(field_name) in 
        ('hs_pipeline', 'hs_pipeline_stage'
    {% for col in var('hubspot__ticket_property_history_columns', []) %}
        , '{{ col }}'
    {%- endfor -%} )

    {% if is_incremental() %}
    and change_timestamp >= (select cast(max(date_day) as {{ dbt.type_timestamp() }}) from {{ this }} )
    {% endif %}

), windows as (

    select
        source_relation,
        cast({{ dbt.date_trunc('day', 'change_timestamp') }} as date) as date_day,
        ticket_id,
        field_name,
        new_value,
        change_source,
        change_source_id,
        change_timestamp as valid_from,
        _fivetran_end as valid_to
        -- if it is currently active fivetran_end = 9999-12-31 23:59:59, but the calendar_spine will end at the current_date
    from history

), order_daily_changes as (

    select 
        *,
        row_number() over (
            partition by date_day, ticket_id, field_name {{ hubspot.partition_by_source_relation() }}
            order by valid_from desc
            ) as row_num
    from windows

), extract_latest as (
    
    select 
        source_relation,
        date_day,
        ticket_id,
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
        {{ dbt_utils.generate_surrogate_key(['field_name','ticket_id','date_day','source_relation']) }} as id
    from extract_latest

)

select *
from surrogate