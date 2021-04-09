{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with deals_enhanced as (

    select *
    from {{ ref('int_hubspot__deals_enhanced') }}

), deal_stage as (

    select *
    from {{ var('deal_stage') }}

), final as (

    select
        deal_stage.deal_id || '-' || row_number() over(partition by deal_stage.deal_id order by deal_stage.date_entered asc) as deal_stage_id,
        deal_stage.deal_stage_name, 
        deal_stage._fivetran_start as date_stage_entered,
        deal_stage._fivetran_end as date_stage_exited,
        deal_stage._fivetran_active as is_stage_active,
        deals_enhanced.*

    from deal_stage

    left join deals_enhanced
        on deal_stage.deal_id = deals_enhanced.deal_id
)

select * 
from final