{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('hubspot_contact_list_enabled', true)
) }}

-- This test will ensure the total count of records from the contact_list staging model matches the end model.
with end_model as (
    select count(*) as end_model_rows
    from {{ ref('hubspot__contact_lists') }}
),

staging_model as (
    select count(*) as staging_model_rows
    from {{ ref('stg_hubspot__contact_list') }}
)

select *
from end_model
cross join staging_model
where end_model_rows != staging_model_rows