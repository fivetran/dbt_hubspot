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
    -- start at the first created contact
        select min( created_date ) as min_date from {{ ref('stg_hubspot__contact') }}
    {% endset %}
    {% set first_date = run_query(first_date_query).columns[0][0]|string %}

    {% else %} {% set first_date = "2016-01-01" %}
    {% endif %}

    select *
    from (
        {{
            dbt_utils.date_spine(
                datepart = "day",
                start_date =  "cast('" ~ first_date[0:10] ~ "' as date)",
                end_date = dbt.dateadd("week", 1, dbt.current_timestamp_in_utc_backcompat())
            )
        }}
    ) as date_spine

    {% if is_incremental() %}
    where date_day >= (select min(date_day) from {{ this }} )
    {% endif %}

), contact as (

    select
        *,
        cast( {{ dbt.date_trunc('day', dbt.current_timestamp_backcompat()) }} as date) as open_until
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
        and cast(calendar.date_day as date) <= contact.open_until

), surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['date_day','contact_id','source_relation']) }} as id
    from joined

)

select *
from surrogate
