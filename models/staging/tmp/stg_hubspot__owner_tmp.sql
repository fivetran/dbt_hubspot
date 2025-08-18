{{ config(enabled=var('hubspot_owner_enabled', true)) }}

select {{ dbt_utils.star(source('hubspot','owner')) }}
from {{ var('owner') }}
