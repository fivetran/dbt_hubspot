{{ config(enabled=(var('hubspot_sales_enabled', true) and var('hubspot_engagement_meeting_enabled', true) and var('hubspot_engagement_enabled', true))) }}

{{ engagements_joined(ref('stg_hubspot__engagement_meeting')) }}