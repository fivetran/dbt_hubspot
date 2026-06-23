{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_form_enabled', 'hubspot_submission_response_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__submission_response_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__submission_response_tmp')),
                staging_columns=get_submission_response_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        conversion_id,
        form_id,
        field_name,
        field_value,
        submitted_at,
        {{ dbt.dateadd(datepart='millisecond',interval='submitted_at', from_date_or_timestamp="cast('1970-01-01' as " ~ dbt.type_timestamp() ~ ")") }} as submitted_timestamp,
        page_url,
        object_type_id,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced
    from macro
)

select *
from fields
