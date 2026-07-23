{{ config(enabled=var('hubspot_marketing_enabled', true) and var('hubspot_marketing_event_enabled', false) and var('hubspot_marketing_event_participant_enabled', false)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__marketing_event_participant_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__marketing_event_participant_tmp')),
                staging_columns=get_marketing_event_participant_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
    from base

), fields as (

    select
        source_relation,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        id as marketing_event_participant_id,
        marketing_event_id,
        contact_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_timestamp,
        cast(properties_occurred_at as {{ dbt.type_timestamp() }}) as occurred_timestamp,
        properties_attendance_percentage as attendance_percentage,
        properties_attendance_state as attendance_state,
        properties_attendance_duration_seconds as attendance_duration_seconds
    from macro

)

select *
from fields
