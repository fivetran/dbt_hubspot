{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_email_event_sent_enabled'])) }}

{{ email_events_joined(ref('stg_hubspot__email_event_sent')) }}