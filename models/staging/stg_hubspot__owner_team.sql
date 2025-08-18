{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_team_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__owner_team_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__owner_team_tmp')),
                staging_columns=get_owner_team_columns()
            )
        }}
    from base

), fields as (

    select
        owner_id,
        team_id,
        is_team_primary,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from macro
)

select *
from fields