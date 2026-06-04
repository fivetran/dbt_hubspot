{{ config(enabled=var('hubspot_service_enabled', false) and var('hubspot_conversation_enabled', false)) }}

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
        {{ hubspot.apply_source_relation() }}
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
