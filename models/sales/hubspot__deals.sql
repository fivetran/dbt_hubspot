with deals as (

    select *
    from {{ var('deal') }}

), engagements as (

    select *
    from {{ ref('hubspot__engagements') }}

), engagement_deals as (

    select *
    from {{ var('engagement_deal') }}

), pipelines as (

    select *
    from {{ var('deal_pipeline') }}

), pipeline_stages as (

    select *
    from {{ var('deal_pipeline_stage') }}

), owners as (

    select *
    from {{ var('owner') }}

), engagement_deal_joined as (

    select
        engagements.engagement_type,
        engagement_deals.deal_id
    from engagements
    inner join engagement_deals
        using (engagement_id)

), engagement_deal_agg as (

    {{ engagements_aggregated('engagement_deal_joined', 'deal_id') }}

), engagements_joined as (

    select 
        deals.*,
        {% for metric in engagement_metrics() %}
        coalesce(engagement_deal_agg.{{ metric }},0) as {{ metric }} {% if not loop.last %},{% endif %}
        {% endfor %}
    from deals
    left join engagement_deal_agg
        using (deal_id)

), deal_fields_joined as (

    select 
        engagements_joined.*,
        pipelines.pipeline_label,
        pipeline_stages.pipeline_stage_label,
        owners.email_address as owner_email_address,
        owners.full_name as owner_full_name
    from engagements_joined
    left join pipelines
        using (deal_pipeline_id)
    left join pipeline_stages
        using (deal_pipeline_stage_id)
    left join owners
        using (owner_id)

)

select *
from deal_fields_joined