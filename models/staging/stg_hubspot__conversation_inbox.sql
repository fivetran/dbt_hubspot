{{ config(enabled=var('hubspot_conversation_enabled', true)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__conversation_inbox_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__conversation_inbox_tmp')),
                staging_columns=get_conversation_inbox_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
    from base

), fields as (

    select
        source_relation,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        _fivetran_deleted as is_deleted,
        id as inbox_id,
        active as is_active,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        name,
        upper(type) as type,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at
    from macro

)

select *
from fields
