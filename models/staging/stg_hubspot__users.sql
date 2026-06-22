{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_role_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__users_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__users_tmp')),
                staging_columns=get_users_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        id as user_id,
        primary_team_id,
        role_id,
        email,
        first_name,
        last_name,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        _fivetran_deleted as is_deleted
    from macro
)

select *
from fields