{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_team_enabled', 'hubspot_team_user_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','team_user')) }}
from {{ var('team_user') }}