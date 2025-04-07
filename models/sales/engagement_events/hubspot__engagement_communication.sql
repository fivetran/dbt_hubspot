{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_communication_enabled','hubspot_engagement_enabled'])) }}

{{ engagements_joined(ref('stg_hubspot__engagement_communication')) }}