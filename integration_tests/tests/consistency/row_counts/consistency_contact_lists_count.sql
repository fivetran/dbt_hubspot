{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('hubspot_contact_list_enabled', true)
) }}

-- this test is to make sure the rows counts are the same between versions
with prod as (
    select count(*) as prod_rows
    from {{ target.schema }}_hubspot_prod.hubspot__contact_lists
),

dev as (
    select count(*) as dev_rows
    from {{ target.schema }}_hubspot_dev.hubspot__contact_lists
)

-- test will return values and fail if the row counts don't match
select *
from prod
cross join dev
where prod.prod_rows != dev.dev_rows