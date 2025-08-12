{{ config(enabled=var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_communication_enabled', false)) }}

select {{ dbt_utils.star(source('hubspot','engagement_communication')) }}
from {{ var('engagement_communication') }}
