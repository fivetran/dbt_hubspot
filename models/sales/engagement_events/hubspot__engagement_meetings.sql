{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_meeting_enabled','hubspot_engagement_enabled'])) }}

{{ engagements_joined(var('engagement_meeting')) }}