{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_team_enabled', 'hubspot_team_user_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__team_user_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__team_user_tmp')),
                staging_columns=get_team_user_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        team_id,
        user_id,
        is_secondary_user,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from macro
)

select *
from fields