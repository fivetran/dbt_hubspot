{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_team_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','team')) }}
from {{ var('team') }}