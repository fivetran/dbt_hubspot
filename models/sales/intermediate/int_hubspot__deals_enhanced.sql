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
        source_relation,
        deal_id,
        {{ fivetran_utils.array_agg("merged_deal_id") }} as merged_deal_ids
    from merged_deals
    group by 1, 2
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

        {{ "," ~ dbt_utils.star(ref('int_hubspot__owners_enhanced'), except=["owner_id", "source_relation"], relation_alias="owners_enhanced") if owner_enabled }}

    from deals    
    left join pipelines
        on deals.deal_pipeline_id = pipelines.deal_pipeline_id
        and deals.source_relation = pipelines.source_relation
    left join pipeline_stages
        on deals.deal_pipeline_stage_id = pipeline_stages.deal_pipeline_stage_id
        and deals.source_relation = pipeline_stages.source_relation

    {% if owner_enabled %}
    left join owners_enhanced
        on deals.owner_id = owners_enhanced.owner_id
        and deals.source_relation = owners_enhanced.source_relation
    {% endif %}

    {% if merged_deal_enabled %}
    left join aggregate_merged_deals
        on deals.deal_id = aggregate_merged_deals.deal_id
        and deals.source_relation = aggregate_merged_deals.source_relation

    left join merged_deals
        on deals.deal_id = merged_deals.merged_deal_id
        and deals.source_relation = merged_deals.source_relation
    where merged_deals.merged_deal_id is null
    {% endif %}
)   

select *
from deal_fields_joined