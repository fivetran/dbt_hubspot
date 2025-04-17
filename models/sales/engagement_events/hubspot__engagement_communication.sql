{{ config(enabled=var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_communication_enabled', false)) }}

{{ engagements_joined(ref('stg_hubspot__engagement_communication')) }}