{{ config(enabled=(var('hubspot__standardized_marketing_model_enabled', False)
    and fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_email_event_sent_enabled'])))
}}

with events as (

    select *
    from {{ ref('hubspot__email_sends') }} 
),

standardized as (

    select 
        event_id,
        coalesce(email_send_timestamp, created_timestamp) as activity_timestamp,
        email_campaign_id as campaign_id,
        recipient_email_address as email,
        contact_id,
        'email send' as event_type,
        cast(null as {{ dbt.type_numeric() }}) as event_value,    
        cast(null as {{ dbt.type_timestamp() }}) as updated_at,
        email_subject,
        bounces as total_bounces,
        clicks as total_clicks,
        deferrals as total_deferrals,
        deliveries as total_deliveries,
        drops as total_drops,
        forwards as total_forwards,
        opens as total_opens,
        spam_reports as total_spam_reports,
        unsubscribes as total_unsubscribes,
        was_bounced,
        was_clicked,
        was_deferred,
        was_delivered,
        was_forwarded,
        was_opened,
        was_unsubscribed 
    from events
)

select *
from standardized