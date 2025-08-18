{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_form_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__contact_form_submission_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__contact_form_submission_tmp')),
                staging_columns=get_contact_form_submission_columns()
            )
        }}
    from base

), fields as (

    select
        cast(timestamp as {{ dbt.type_timestamp() }}) as occurred_timestamp,
        form_id,
        contact_id,
        conversion_id,
        page_id,
        page_url,
        portal_id,
        title,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from macro
)

select *
from fields