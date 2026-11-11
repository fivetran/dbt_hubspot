{{ config(enabled=(var('hubspot_sales_enabled', true) and var('hubspot_engagement_task_enabled', true) and var('hubspot_engagement_enabled', true))) }}

{{ engagements_joined(ref('stg_hubspot__engagement_task')) }}