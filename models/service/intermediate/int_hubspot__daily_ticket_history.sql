{{
    config(
        enabled=var('hubspot_service_enabled', False),
        materialized='incremental',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='id',
        incremental_strategy = 'merge' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}
{# {{ config(enabled=false) }} #}
with history as (

    select *
    from {{ var('ticket_property_history') }}

    -- find a more elegant way in jinja to concat lists when one may be empty 
    where lower(field_name) in 
        ('hs_pipeline', 'hs_pipeline_stage'
    {% for col in var('hubspot__ticket_field_history_columns', []) %}
        , '{{ col }}'
    {%- endfor -%} )

    {% if is_incremental() %}
    and vaid_from >= (select max(date_day) from {{ this }} )
    {% endif %}

), windows as (

    select
        cast({{ dbt.date_trunc('day', 'change_timestamp') }} as date) as date_day,
        ticket_id,
        field_name,
        change_source,
        change_source_id,
        change_timestamp as valid_from,
        new_value,
        lead(change_timestamp) over (partition by ticket_id, field_name order by change_timestamp) as valid_to
    from history

), order_daily_changes as (

    select 
        *,
        row_number() over (
            partition by date_day, ticket_id, field_name
            order by valid_from desc
            ) as row_num,
        row_number() over (
            partition by date_day, ticket_id, field_name
            order by valid_from asc
            ) as nth_change

    from windows

), extract_latest as (
    
    select 
        date_day,
        ticket_id,
        field_name,
        new_value,
        change_source,
        change_source_id,
        valid_from,
        valid_to,
        nth_change as number_of_changes

    from order_daily_changes
    where row_num = 1

), surrogate as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['field_name','ticket_id','date_day']) }} as id
    from extract_latest

)

select *
from surrogate