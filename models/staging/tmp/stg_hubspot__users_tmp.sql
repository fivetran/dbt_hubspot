{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_role_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','users')) }}
from {{ var('users') }}