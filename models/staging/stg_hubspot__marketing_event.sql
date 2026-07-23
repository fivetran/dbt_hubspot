{{ config(enabled=var('hubspot_marketing_enabled', true) and var('hubspot_marketing_event_enabled', false)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__marketing_event_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__marketing_event_tmp')),
                staging_columns=get_marketing_event_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
    from base

), fields as (

    select
        source_relation,
        _fivetran_deleted as is_marketing_event_deleted,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        id as marketing_event_id,
        app_id,
        app_name,
        attendees,
        cancellations,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_timestamp,
        cast(end_date_time as {{ dbt.type_timestamp() }}) as end_timestamp,
        event_cancelled,
        event_completed,
        event_description,
        event_name,
        event_organizer,
        event_status,
        event_type,
        event_url,
        external_event_id,
        no_shows,
        registrants,
        cast(start_date_time as {{ dbt.type_timestamp() }}) as start_timestamp,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_timestamp
    from macro

)

select *
from fields
