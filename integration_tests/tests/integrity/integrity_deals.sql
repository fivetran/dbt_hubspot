{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('hubspot_deal_enabled', true)
) }}

-- This tests for fanout. Returns records if the staging model does not match the end model.
with end_model as (
    select count(*) as end_model_rows
    from {{ ref('hubspot__deals') }}
),

staging_model as (
    select count(*) as staging_model_rows
    from {{ ref('stg_hubspot__deal') }}
)

select *
from end_model
cross join staging_model
where end_model_rows != staging_model_rows