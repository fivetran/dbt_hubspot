{{ config(enabled=var('hubspot_owner_enabled', true)) }}

with owners as (
    select
        source_relation,
        owner_id,
        active_user_id as owner_active_user_id,
        email_address as owner_email_address,
        full_name as owner_full_name
    from {{ ref('stg_hubspot__owner') }}
{% set cte_ref = 'owners' %}

{% if var('hubspot_team_enabled', true) %}
), owner_teams as (
    select *
    from {{ ref('stg_hubspot__owner_team') }}

), teams as (
    select *
    from {{ ref('stg_hubspot__team') }}

), teams_agg as (
    select
        owner_teams.source_relation,
        owner_teams.owner_id,
        max(case when owner_teams.is_team_primary then owner_teams.team_id end) as owner_primary_team_id,
        max(case when owner_teams.is_team_primary then teams.team_name end) as owner_primary_team_name,
        {{ dbt.listagg(measure="cast(teams.team_id as " ~ dbt.type_string() ~ ")", delimiter_text="','", order_by_clause="order by teams.team_id") }} as owner_all_team_ids,
        {{ dbt.listagg(measure="teams.team_name", delimiter_text="','", order_by_clause="order by teams.team_id") }} as owner_all_team_names
    from owner_teams
    left join teams
        on owner_teams.team_id = teams.team_id
        and owner_teams.source_relation = teams.source_relation
    group by 1, 2

), teams_joined as (
    select
        owners.*,
        teams_agg.owner_primary_team_id,
        teams_agg.owner_primary_team_name,
        teams_agg.owner_all_team_ids,
        teams_agg.owner_all_team_names
    from owners
    left join teams_agg
    on owners.owner_id = teams_agg.owner_id
    and owners.source_relation = teams_agg.source_relation
{% set cte_ref = 'teams_joined' %}
{% endif %}

{% if var('hubspot_role_enabled', true) %}
), users as (
    select *
    from {{ ref('stg_hubspot__users') }}

), roles as (
    select *
    from {{ ref('stg_hubspot__role') }}

), roles_joined as (
    select
        {{ cte_ref }}.*,
        users.role_id as owner_role_id,
        roles.role_name as owner_role_name
    from {{ cte_ref }}
    left join users
        on {{ cte_ref }}.owner_active_user_id = users.user_id
        and {{ cte_ref }}.source_relation = users.source_relation
    left join roles
        on users.role_id = roles.role_id
        and users.source_relation = roles.source_relation

{% set cte_ref = 'roles_joined' %}
{% endif %}
)   

select *
from {{ cte_ref }}