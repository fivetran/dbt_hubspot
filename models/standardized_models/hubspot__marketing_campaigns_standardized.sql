{{ config(enabled=(var('hubspot__standardized_marketing_model_enabled', False)
        and fivetran_utils.enabled_vars(['hubspot_marketing_enabled','hubspot_email_event_enabled','hubspot_email_event_sent_enabled']))) 
}}

with campaigns as (

    select *
    from {{ ref('hubspot__email_campaigns') }} 
),

standardized as (

    select 
        email_campaign_id as campaign_id,
        email_campaign_name as campaign_name,
        email_campaign_type as campaign_type,
        email_campaign_sub_type as campaign_sub_type,
        email_campaign_subject as campaign_subject,
        coalesce(app_id, content_id) as secondary_id,
        cast(null as {{ dbt.type_timestamp() }}) as created_at,
        cast(null as {{ dbt.type_timestamp() }}) as updated_at,
        total_bounces,
        total_clicks,
        total_deferrals,
        total_deliveries,
        total_opens,
        total_unsubscribes,
        total_unique_clicks,
        total_unique_opens
    from campaigns
)

select *
from standardized