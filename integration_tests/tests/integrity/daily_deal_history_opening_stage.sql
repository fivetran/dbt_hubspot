{{ config(enabled=var('hubspot__daily_history_start_date', none) == '2021-01-08'
    and fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_deal_property_history_enabled'])) }}

with expected as (

    -- The seeded stage for the first deal was entered the day before the cutoff.
    select cast(3954699413 as {{ dbt.type_bigint() }}) as deal_id, 'f66ca9bc5a02c2f1513ce83f0a0e117d' as new_value
    union all
    select cast(3960154657 as {{ dbt.type_bigint() }}), '09a969da1d61b38bd3746f0f49c1475a'

), actual as (

    select deal_id, new_value
    from {{ ref('int_hubspot__daily_deal_history') }}
    where date_day = cast('2021-01-08' as date)
      and field_name = 'pipeline_stage_id'

)

select expected.deal_id
from expected
left join actual
    on expected.deal_id = actual.deal_id
    and expected.new_value = actual.new_value
where actual.deal_id is null
