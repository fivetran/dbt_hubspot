{{ config(enabled=var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_communication_enabled', false)) }}

with base as (

    select *
    from {{ ref('stg_hubspot__engagement_communication_tmp') }}

), macro as (

    select 
        {% set default_cols = adapter.get_columns_in_relation(ref('stg_hubspot__engagement_communication_tmp')) %}
        {% set new_cols = remove_duplicate_and_prefix_from_columns(columns=default_cols, 
            prefix='property_hs_',exclude=get_macro_columns(get_engagement_communication_columns())) %}
        {{
            fivetran_utils.fill_staging_columns(source_columns=default_cols,
                staging_columns=get_engagement_communication_columns()
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


