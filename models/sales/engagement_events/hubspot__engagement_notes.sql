{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_note_enabled','hubspot_engagement_enabled'])) }}

{{ engagements_joined(var('engagement_note')) }}