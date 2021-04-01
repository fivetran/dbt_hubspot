{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with deals as (

    select *
    from {{ var('deal') }}

), deal_stage as (

    select *
    from {{ var('deal_stage') }}

), pipelines as (

    select *
    from {{ var('deal_pipeline') }}

), pipeline_stages as (

    select *
    from {{ var('deal_pipeline_stage') }}

), owners as (

    select *
    from {{ var('owner') }}

{% if var('hubspot_deal_company_enabled', True) %}
),  deal_company as (

    select *
    from {{ var('deal_company') }}

), company as (
    select * 
    from {{ var('company') }}

{% endif %}

), deal_fields_joined as (

    select 
        deals.*,
        pipelines.pipeline_label,
        pipelines.is_active as is_pipeline_active,
        pipeline_stages.pipeline_stage_label,
        owners.email_address as owner_email_address,
        owners.full_name as owner_full_name

        {% if var('hubspot_deal_company_enabled', True) %}
        ,company.*
        {% endif %}


    from deals
    left join pipelines
        using (deal_pipeline_id)
    left join pipeline_stages
        using (deal_pipeline_stage_id)
    left join owners
        using (owner_id)

    {% if var('hubspot_deal_company_enabled', True) %}
    left join deal_company
        on deals.deal_id = deal_company.deal_id

    left join company
        on deal_company.company_id = company.company_id
    {% endif %}

), final as (

    select
        concat(deal_stage.deal_id,'-', row_number() over(partition by deal_stage.deal_id order by deal_stage.date_entered asc)) as deal_stage_id,
        deal_stage.deal_stage_name,
        deal_stage._fivetran_start as date_stage_entered,
        deal_stage._fivetran_end as date_stage_exited,
        deal_stage._fivetran_active as is_stage_active,
        deal_fields_joined.*

    from deal_stage

    left join deal_fields_joined
        on deal_stage.deal_id = deal_fields_joined.deal_id
)

select * 
from final