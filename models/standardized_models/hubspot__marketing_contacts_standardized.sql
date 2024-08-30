{{ config(enabled=(var('hubspot__standardized_marketing_model_enabled', False)
        and fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled']))) 
}}

{% set emails_enabled = fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_email_event_enabled', 'hubspot_email_event_sent_enabled']) %}
{% set engagements_enabled = fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_engagement_enabled','hubspot_engagement_contact_enabled']) %}

with contacts as (

    select *
    from {{ ref('hubspot__contacts') }} 
),

standardized as (

    select 
        contact_id,
        first_name,
        last_name,
        email,
        contact_company,
        cast(created_date as {{ dbt.type_timestamp() }}) as created_at,
        cast(null as {{ dbt.type_string() }}) as contact_phone,
        cast(null as {{ dbt.type_timestamp() }}) as updated_at,
        cast(null as {{ dbt.type_string() }}) as contact_address,
        cast(null as {{ dbt.type_string() }}) as contact_city,
        cast(null as {{ dbt.type_string() }}) as contact_state,
        cast(null as {{ dbt.type_string() }}) as contact_country,
        cast(null as {{ dbt.type_string() }}) as contact_timezone,
        cast(null as {{ dbt.type_string() }}) as contact_language,
        cast(null as {{ dbt.type_timestamp() }}) as first_event_at,
        cast(null as {{ dbt.type_timestamp() }}) as last_event_at,
        cast(null as {{ dbt.type_string() }}) as contact_status,
        total_bounces,
        total_clicks,
        total_deferrals,
        total_deliveries,
        total_drops,
        total_forwards,
        total_opens,
        cast(null as {{ dbt.type_int() }}) as total_unsubscribes,
        count_engagement_emails as total_sends, -- check this
        cast(null as {{ dbt.type_int() }}) as total_replies,   
        cast(null as {{ dbt.type_int() }}) as total_responses,    
        total_unique_opens,
        total_unique_clicks
    from contacts
)

select * 
from standardized