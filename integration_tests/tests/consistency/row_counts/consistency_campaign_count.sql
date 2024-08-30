{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

-- this test is to make sure the rows counts are the same between versions
with prod as (
    select count(*) as prod_rows
    from {{ target.schema }}_hubspot_prod.hubspot__email_campaigns
),

dev as (
    select count(*) as dev_rows
    from {{ target.schema }}_hubspot_dev.hubspot__email_campaigns
)

-- test will return values and fail if the row counts don't match
select *
from prod
join dev
    on prod.prod_rows != dev.dev_rows