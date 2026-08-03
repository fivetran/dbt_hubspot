{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_company_list_enabled'])) }}

with base as (

    select *
    from {{ ref('stg_hubspot__company_list_tmp') }}

), macro as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__company_list_tmp')),
                staging_columns=get_company_list_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
    from base

), fields as (

    select

{% if var('hubspot__pass_through_all_columns', false) %}
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_hubspot__company_list_tmp')),
                staging_columns=get_company_list_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='hubspot') }}
        {% if all_passthrough_column_check('stg_hubspot__company_list_tmp',get_company_list_columns()) > 0 %}
        -- just pass everything through if extra columns are present, but ensure required columns are present.
        {% set exclude_cols = ['_dbt_source_relation'] + get_macro_columns(get_company_list_columns()) %}
        {{
            remove_duplicate_and_prefix_from_columns(
                columns=adapter.get_columns_in_relation(ref('stg_hubspot__company_list_tmp')),
                prefix='property_', exclude=exclude_cols)
        }}
        {% endif %}
    from base

{% else %}
        -- just default columns + explicitly configured passthrough columns
        source_relation,
        company_list_id,
        company_list_name,
        created_by_id,
        object_type_id,
        processing_status,
        processing_type,
        list_version,
        filters_updated_at,
        is_company_list_deleted,
        cast(updated_timestamp as {{ dbt.type_timestamp() }}) as updated_timestamp,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced,
        cast(created_timestamp as {{ dbt.type_timestamp() }}) as created_timestamp

        --The below macro adds the fields defined within your hubspot__company_list_pass_through_columns variable into the staging model
        {{ fivetran_utils.fill_pass_through_columns('hubspot__company_list_pass_through_columns') }}

    from macro
{% endif %}

), joined as (
    {{ add_property_labels('hubspot__company_list_pass_through_columns', cte_name='fields') }}
)

select *
from joined
