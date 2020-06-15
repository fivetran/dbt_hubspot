{% macro email_events_aggregate(base_model, aggregate_name) %}

with base as (

    select *
    from {{ base_model }}

), aggregates as (

    select
        email_campaign_id,
        email_send_id,
        count(*) as {{ aggregate_name }}
    from base
    where email_send_id is not null
    group by 1,2

)

select *
from aggregates

{% endmacro %}