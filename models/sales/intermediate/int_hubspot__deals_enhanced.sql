{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}
{% set merged_deal_enabled = var('hubspot_merged_deal_enabled', false) %}
{% set owner_enabled = var('hubspot_owner_enabled', true) %}

with deals as (

    select *
    from {{ ref('stg_hubspot__deal') }}

{% if merged_deal_enabled %}
), merged_deals as (

    select *
    from {{ ref('stg_hubspot__merged_deal') }}

), aggregate_merged_deals as (

    select
        deal_id,
        {{ fivetran_utils.array_agg("merged_deal_id") }} as merged_deal_ids
    from merged_deals
    group by 1
{% endif %}

), pipelines as (

    select *
    from {{ ref('stg_hubspot__deal_pipeline') }}

), pipeline_stages as (

    select *
    from {{ ref('stg_hubspot__deal_pipeline_stage') }}

{% if owner_enabled %}
), owners_enhanced as (

    select *
    from {{ ref('int_hubspot__owners_enhanced') }}
{% endif %}

), deal_fields_joined as (

    select 
        deals.*,

        {{ 'aggregate_merged_deals.merged_deal_ids,' if merged_deal_enabled }}

        coalesce(pipelines.is_deal_pipeline_deleted, false) as is_deal_pipeline_deleted,
        pipelines.pipeline_label,
        pipelines.is_active as is_pipeline_active,
        coalesce(pipeline_stages.is_deal_pipeline_stage_deleted, false) as is_deal_pipeline_stage_deleted,
        pipelines.deal_pipeline_created_at,
        pipelines.deal_pipeline_updated_at,
        pipeline_stages.pipeline_stage_label

        {{ "," ~ dbt_utils.star(ref('int_hubspot__owners_enhanced'), except=["owner_id"], relation_alias="owners_enhanced") if owner_enabled }}

    from deals    
    left join pipelines 
        on deals.deal_pipeline_id = pipelines.deal_pipeline_id
    left join pipeline_stages 
        on deals.deal_pipeline_stage_id = pipeline_stages.deal_pipeline_stage_id

    {% if owner_enabled %}
    left join owners_enhanced
        on deals.owner_id = owners_enhanced.owner_id
    {% endif %}

    {% if merged_deal_enabled %}
    left join aggregate_merged_deals
        on deals.deal_id = aggregate_merged_deals.deal_id

    left join merged_deals
        on deals.deal_id = merged_deals.merged_deal_id
    where merged_deals.merged_deal_id is null
    {% endif %}
)   

select *
from deal_fields_joined