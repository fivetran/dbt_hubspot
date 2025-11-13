{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_form_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__form_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__form_tmp')),
                staging_columns=get_form_columns()
            )
        }}
        {{ hubspot.apply_source_relation() }}
    from base

), fields as (

    select
        source_relation,
        guid as form_id,
        action,
        created_at,
        css_class,
        follow_up_id,
        form_type,
        lead_nurturing_campaign_id,
        method,
        name as form_name,
        notify_recipients,
        portal_id,
        redirect,
        submit_text,
        updated_at,
        _fivetran_deleted as is_deleted

    from macro
)

select *
from fields