{{ config(
    tags="fivetran_validations",
    enabled=(var('fivetran_validation_tests_enabled', false) and var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_spam_report_enabled', true))
) }}

{% set exclude_cols = var('consistency_test_exclude', []) %}

-- this test ensures the email event spam report end model matches the prior version
with prod as (
    select {{ dbt_utils.star(from=ref('hubspot__email_event_spam_report'), except=exclude_cols) }}
    from {{ target.schema }}_hubspot_prod.hubspot__email_event_spam_report
),

dev as (
    select {{ dbt_utils.star(from=ref('hubspot__email_event_spam_report'), except=exclude_cols) }}
    from {{ target.schema }}_hubspot_dev.hubspot__email_event_spam_report
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