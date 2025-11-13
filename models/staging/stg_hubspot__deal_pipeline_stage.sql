{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__deal_pipeline_stage_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__deal_pipeline_stage_tmp')),
                staging_columns=get_deal_pipeline_stage_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        _fivetran_deleted as is_deal_pipeline_stage_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        active as is_active,
        coalesce(is_closed, closed_won) as is_closed,
        display_order,
        label as pipeline_stage_label,
        cast(pipeline_id as {{ dbt.type_string() }}) as deal_pipeline_id,
        probability,
        cast(stage_id as {{ dbt.type_string() }}) as deal_pipeline_stage_id,
        created_at as deal_pipeline_stage_created_at,
        updated_at as deal_pipeline_stage_updated_at
    from macro
    
)

select *
from fields