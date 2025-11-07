{{ config(enabled=var('hubspot_service_enabled', False)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__ticket_company_tmp') }}

), macro as (

    select
        {% set default_cols = adapter.get_columns_in_relation(ref('stg_hubspot__ticket_company_tmp')) %}
        {% set exclude_cols = ['_dbt_source_relation'] + get_macro_columns(get_ticket_company_columns()) %}

        {% set new_cols = remove_duplicate_and_prefix_from_columns(columns=default_cols, 
            prefix='property_hs_',exclude=exclude_cols) %}
        {{
            fivetran_utils.fill_staging_columns(source_columns=default_cols,
                staging_columns=get_ticket_company_columns()
            )
        }}
        {% if new_cols | length > 0 %}
            {{ new_cols }}
        {% endif %}
        {{ hubspot.apply_source_relation() }}
    from base

)

select *
from macro
