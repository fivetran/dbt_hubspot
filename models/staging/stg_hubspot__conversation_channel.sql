{{ config(enabled=var('hubspot_conversation_enabled', true)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__conversation_channel_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__conversation_channel_tmp')),
                staging_columns=get_conversation_channel_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
    from base

), fields as (

    select
        source_relation,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        _fivetran_deleted as is_deleted,
        id as channel_id,
        name
    from macro

)

select *
from fields
