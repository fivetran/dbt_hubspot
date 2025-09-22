{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('hubspot_contact_enabled', true)
) }}

-- This tests for fanout. Returns records if the staging model does not match the end model.
with end_model as (
    select count(*) as end_model_rows
    from {{ ref('hubspot__contacts') }}
),

int_model as (
    select count(*) as int_model_rows
    from {{ ref('int_hubspot__contact_merge_adjust') }}
),

staging_model as (
    select count(*) as staging_model_rows
    from {{ ref('stg_hubspot__contact') }}
)

select *
from end_model
cross join staging_model
cross join int_model
where end_model_rows > staging_model_rows -- changed from = to > becasuse of merges
    or end_model_rows != int_model_rows