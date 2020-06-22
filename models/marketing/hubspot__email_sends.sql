with sends as (

    select *
    from {{ ref('hubspot__email_event_sent') }}

), bounces as (

    select *
    from {{ ref('int_hubspot__email_aggregate_bounces') }}

), clicks as (

    select *
    from {{ ref('int_hubspot__email_aggregate_clicks') }}

), deferrals as (

    select *
    from {{ ref('int_hubspot__email_aggregate_deferred') }}

), deliveries as (

    select *
    from {{ ref('int_hubspot__email_aggregate_delivered') }}

), drops as (

    select *
    from {{ ref('int_hubspot__email_aggregate_dropped') }}

), forwards as (

    select *
    from {{ ref('int_hubspot__email_aggregate_forward') }}

), opens as (

    select *
    from {{ ref('int_hubspot__email_aggregate_opens') }}

), prints as (

    select *
    from {{ ref('int_hubspot__email_aggregate_print') }}

), spam_reports as (

    select *
    from {{ ref('int_hubspot__email_aggregate_spam_report') }}

), unsubscribes as (

    select *
    from {{ ref('int_hubspot__email_aggregate_status_change') }}

), joined as (

    select
        sends.*,
        coalesce(bounces.bounces,0) as bounces,
        coalesce(clicks.clicks,0) as clicks,
        coalesce(deferrals.deferrals,0) as deferrals,
        coalesce(deliveries.deliveries,0) as deliveries,
        coalesce(drops.drops,0) as drops,
        coalesce(forwards.forwards,0) as forwards,
        coalesce(opens.opens,0) as opens,
        coalesce(prints.prints,0) as prints,
        coalesce(spam_reports.spam_reports,0) as spam_reports,
        coalesce(unsubscribes.unsubscribes,0) as unsubscribes   
    from sends
    left join bounces using (email_send_id)
    left join clicks using (email_send_id)
    left join deferrals using (email_send_id)
    left join deliveries using (email_send_id)
    left join drops using (email_send_id)
    left join forwards using (email_send_id)
    left join opens using (email_send_id)
    left join prints using (email_send_id)
    left join spam_reports using (email_send_id)
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