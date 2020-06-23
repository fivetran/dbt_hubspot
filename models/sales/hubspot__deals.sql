with deals as (

    select *
    from {{ var('deal') }}

), engagements as (

    select *
    from {{ ref('hubspot__engagements') }}

), engagement_deals as (

    select *
    from {{ var('engagement_deal') }}

), engagement_deal_joined as (

    select
        engagements.engagement_type,
        engagement_deals.deal_id
    from engagements
    left join engagement_deals
        using (engagement_id)

), engagement_deal_agg as (

    {{ engagements_aggregated('engagement_deal_joined', 'deal_id') }}

), joined as (

    select 
        deals.*,
        {% for metric in engagement_metrics() %}
        engagement_deal_agg.{{ metric }} {% if not loop.last %},{% endif %}
        {% endfor %}
    from deals
    left join engagement_deal_agg
        using (deal_id)

)

select *
from joined