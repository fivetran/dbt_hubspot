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
        coalesce(bounces.bounces,0) as bounces
    from sends
    left join bounces using (email_send_id)

)

select *
from joined