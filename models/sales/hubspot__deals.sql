{{ config(enabled=enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with deals as (

    select *
    from {{ var('deal') }}

), pipelines as (

    select *
    from {{ var('deal_pipeline') }}

), pipeline_stages as (

    select *
    from {{ var('deal_pipeline_stage') }}

), owners as (

    select *
    from {{ var('owner') }}

), deal_fields_joined as (

    select 
        deals.*,
        pipelines.pipeline_label,
        pipeline_stages.pipeline_stage_label,
        owners.email_address as owner_email_address,
        owners.full_name as owner_full_name
    from deals
    left join pipelines
        using (deal_pipeline_id)
    left join pipeline_stages
        using (deal_pipeline_stage_id)
    left join owners
        using (owner_id)

{% if enabled_vars(['hubspot_engagement_enabled','hubspot_engagement_deal_enabled']) %}

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
    inner join engagement_deals
        using (engagement_id)

), engagement_deal_agg as (

    {{ engagements_aggregated('engagement_deal_joined', 'deal_id') }}

), engagements_joined as (

    select 
        deal_fields_joined.*,
        {% for metric in engagement_metrics() %}
        coalesce(engagement_deal_agg.{{ metric }},0) as {{ metric }} {% if not loop.last %},{% endif %}
        {% endfor %}
    from deal_fields_joined
    left join engagement_deal_agg
        using (deal_id)

)

select *
from engagements_joined

{% else %}

)

select *
from deal_fields_joined

{% endif %}