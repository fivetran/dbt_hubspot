{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with deals as (

    select *
    from {{ var('deal') }}

), pipelines as (

    select *
    from {{ var('deal_pipeline') }}

), pipeline_stages as (

    select *
    from {{ var('deal_pipeline_stage') }}

{% if var('hubspot_owner_enabled', true) %}
), owners as (

    select *
    from {{ var('owner') }}
{% endif %}

), deal_fields_joined as (

    select 
        deals.*,
        coalesce(pipelines.is_deal_pipeline_deleted, false) as is_deal_pipeline_deleted,
        pipelines.pipeline_label,
        pipelines.is_active as is_pipeline_active,
        coalesce(pipeline_stages.is_deal_pipeline_stage_deleted, false) as is_deal_pipeline_stage_deleted,
        pipelines.deal_pipeline_created_at,
        pipelines.deal_pipeline_updated_at,
        pipeline_stages.pipeline_stage_label

        {% if var('hubspot_owner_enabled', true) %}
        , owners.email_address as owner_email_address
        , owners.full_name as owner_full_name
        {% endif %}

    from deals    
    left join pipelines 
        on deals.deal_pipeline_id = pipelines.deal_pipeline_id
        and deals.source_relation = pipelines.source_relation
    left join pipeline_stages 
        on deals.deal_pipeline_stage_id = pipeline_stages.deal_pipeline_stage_id
        and deals.source_relation = pipeline_stages.source_relation

    {% if var('hubspot_owner_enabled', true) %}
    left join owners 
        on deals.owner_id = owners.owner_id
        and deals.source_relation = owners.source_relation
    {% endif %}
)

select *
from deal_fields_joined