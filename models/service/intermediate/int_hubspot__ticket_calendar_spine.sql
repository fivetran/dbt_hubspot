{# {{ config(enabled=var('hubspot_service_enabled', False)) }} #}
{{ config(enabled=false) }}
{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2019-01-01' as date)",
    end_date="current_date"
   )
}}