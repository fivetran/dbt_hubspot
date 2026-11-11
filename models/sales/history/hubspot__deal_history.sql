{{ config(enabled=(var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) and var('hubspot_deal_property_history_enabled', true))) }}

with history as (

    select *
    from {{ ref('stg_hubspot__deal_property_history') }}

), windows as (

    select
        source_relation,
        deal_id,
        field_name,
        change_source,
        change_source_id,
        change_timestamp as valid_from,
        new_value,
        lead(change_timestamp) over (partition by deal_id, field_name {{ fivetran_utils.partition_by_source_relation(package_name='hubspot') }} order by change_timestamp) as valid_to
    from history

), surrogate as (

    select 
        windows.*,
        {{ dbt_utils.generate_surrogate_key(['field_name','deal_id','valid_from','source_relation']) }} as id
    from windows

)

select *
from surrogate