with sends as (

    select *
    from {{ ref('hubspot__email_event_sent') }}

), metrics as (

    select *
    from {{ ref('int_hubspot__email_event_aggregates') }}

), unsubscribes as (

    select *
    from {{ ref('int_hubspot__email_aggregate_status_change') }}

), joined as (

    select
        sends.*,
        coalesce(metrics.bounces,0) as bounces,
        coalesce(metrics.clicks,0) as clicks,
        coalesce(metrics.deferrals,0) as deferrals,
        coalesce(metrics.deliveries,0) as deliveries,
        coalesce(metrics.drops,0) as drops,
        coalesce(metrics.forwards,0) as forwards,
        coalesce(metrics.opens,0) as opens,
        coalesce(metrics.prints,0) as prints,
        coalesce(metrics.spam_reports,0) as spam_reports,
        coalesce(unsubscribes.unsubscribes,0) as unsubscribes   
    from sends
    left join metrics using (email_send_id)
    left join unsubscribes using (email_send_id)

), booleans as (

    select 
        *,
        bounces > 0 as was_bounced,
        clicks > 0 as was_clicked,
        deferrals > 0 as was_deffered,
        deliveries > 0 as was_delivered,
        forwards > 0 as was_forwarded,
        opens > 0 as was_opened,
        prints > 0 as was_printed,
        spam_reports > 0 as was_spam_reported,
        unsubscribes > 0 as was_unsubcribed
    from joined

)

select *
from booleans