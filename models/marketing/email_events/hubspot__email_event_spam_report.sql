{{ config(enabled=(var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_spam_report_enabled', true))) }}

{{ email_events_joined(ref('stg_hubspot__email_event_spam_report')) }}