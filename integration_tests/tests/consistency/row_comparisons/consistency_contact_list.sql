{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('hubspot_contact_list_enabled', true)
) }}

-- this test ensures the contact_list end model matches the prior version
with prod as (
    select 
        {{ dbt_utils.star(
            from=ref('hubspot__contact_lists'), 
            except=var('consistency_test_contact_list_exclude_fields', [])) 
        }}
    from {{ target.schema }}_hubspot_prod.hubspot__contact_lists
),

dev as (
    select 
        {{ dbt_utils.star(
            from=ref('hubspot__contact_lists'), 
            except=var('consistency_test_contact_list_exclude_fields', [])) 
        }}
    from {{ target.schema }}_hubspot_dev.hubspot__contact_lists
),

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final