{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_team_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__team_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__team_tmp')),
                staging_columns=get_team_columns()
            )
        }}
    from base

), fields as (

    select
        id as team_id,
        name as team_name,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from macro
)

select *
from fields