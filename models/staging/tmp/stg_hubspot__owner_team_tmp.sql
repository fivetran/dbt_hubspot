{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_team_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','owner_team')) }}
from {{ var('owner_team') }}