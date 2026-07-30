{{
    config(
        enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_property_enabled', 'hubspot_contact_property_history_enabled']),
        materialized='incremental' if hubspot.is_incremental_compatible() else 'table',
        partition_by = {'field': 'date_day', 'data_type': 'date'}
            if target.type not in ['spark', 'databricks'] else ['date_day'],
        unique_key='id',
        incremental_strategy = 'insert_overwrite' if target.type not in ('snowflake', 'postgres', 'redshift') else 'delete+insert',
        file_format = 'delta'
    )
}}
-- depends_on: {{ ref('stg_hubspot__contact') }}

with calendar as (

    {% if execute and flags.WHICH in ('run', 'build') %}
        {% set first_date_query %}
            {% if is_incremental() %}
                select coalesce(max(date_day), cast('2016-01-01' as date)) from {{ this }}
            {% elif var('hubspot__daily_history_start_date', none) %}
                select cast('{{ var("hubspot__daily_history_start_date") }}' as date)
            {% else %}
                select coalesce(min(created_date), cast('2016-01-01' as {{ dbt.type_timestamp() }})) from {{ ref('stg_hubspot__contact') }}
            {% endif %}
        {% endset %}
        {% set first_date = dbt_utils.get_single_value(first_date_query) | string %}

    {% else %}
        {% set first_date = "2016-01-01" %}
    {% endif %}

    {% set start_date = "cast('" ~ first_date[0:10] ~ "' as date)" %}

    select *
    from (
        {{
            dbt_utils.date_spine(
                datepart = "day",
                start_date = start_date,
                end_date = dbt.dateadd("day", 1, dbt.current_timestamp_in_utc_backcompat())
            )
        }}
    ) as date_spine

), contact as (

    select
        *
    from {{ ref('stg_hubspot__contact') }}
    where not coalesce(is_contact_deleted, false)

), joined as (

    select
        cast(calendar.date_day as date) as date_day,
        contact.contact_id,
        contact.source_relation
    from calendar
    inner join contact
        on cast(calendar.date_day as date) >= cast(contact.created_date as date)

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['date_day','contact_id','source_relation']) }} as id
    from joined

)

select *
from surrogate
