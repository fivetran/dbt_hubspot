{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled'])) }}

with deals as (

    select *
    from {{ var('deal') }}

{% if var('hubspot_merged_deal_enabled', false) %}
), merged_deals as (

    select *
    from {{ var('merged_deal')}}

), aggregate_merged_deals as (

    select
        deal_id,
        {{ fivetran_utils.array_agg("merged_deal_id") }} as merged_deal_ids
    from merged_deals
    group by 1
{% endif %}

), pipelines as (

    select *
    from {{ var('deal_pipeline') }}

), pipeline_stages as (

    select *
    from {{ var('deal_pipeline_stage') }}

{% if var('hubspot_owner_enabled', true) %}
), owners as (
    select *
    from {{ var('owner') }}

{% set cte_ref = 'owners' %}

    {% if var('hubspot_owner_team_enabled', true) and var('hubspot_team_enabled', true) %}
), owner_teams as (
    select *
    from {{ var('owner_team') }}

), teams as (
    select *
    from {{ var('team') }}

), teams_joined as (
    select
        owners.*,
        owner_teams.is_team_primary,
        teams.team_id,
        teams.team_name
    from owners
    left join owner_teams
        on owners.owner_id = owner_teams.owner_id
    left join teams
        on owner_teams.team_id = teams.team_id

{% set cte_ref = 'teams_joined' %}

        {% if var('hubspot_team_user_enabled', true) and var('hubspot_users_enabled', true) %}
), team_users as (
    select *
    from {{ var('team_user') }}

), users as (
    select *
    from {{ var('users') }}

), users_joined as (
    select
        teams_joined.*,
        team_users.is_secondary_user,
        users.user_id,
        users.role_id,
        users.email,
        users.first_name,
        users.last_name
    from teams_joined
    left join team_users
        on teams_joined.team_id = team_users.team_id
    left join users
        on team_users.user_id = users.user_id

{% set cte_ref = 'users_joined' %}

            {% if var('hubspot_role_enabled', true) %}
), roles as (
    select *
    from {{ var('role') }}

), roles_joined as (
    select
        users_joined.*,
        roles.role_name,
        roles.requires_billing_write
    from users_joined
    left join roles
        on users_joined.role_id = roles.role_id

{% set cte_ref = 'roles_joined' %}

            {% endif %}
        {% endif %}
    {% endif %}
{% endif %}

), deal_fields_joined as (

    select 
        deals.*,

        {% if var('hubspot_merged_deal_enabled', false) %}
        aggregate_merged_deals.merged_deal_ids,
        {% endif %}

        coalesce(pipelines.is_deal_pipeline_deleted, false) as is_deal_pipeline_deleted,
        pipelines.pipeline_label,
        pipelines.is_active as is_pipeline_active,
        coalesce(pipeline_stages.is_deal_pipeline_stage_deleted, false) as is_deal_pipeline_stage_deleted,
        pipelines.deal_pipeline_created_at,
        pipelines.deal_pipeline_updated_at,
        pipeline_stages.pipeline_stage_label

        {% if var('hubspot_owner_enabled', true) %}
        , owners.email_address as owner_email_address
        , owners.full_name as owner_full_name
        {% endif %}

    from deals    
    left join pipelines 
        on deals.deal_pipeline_id = pipelines.deal_pipeline_id
    left join pipeline_stages 
        on deals.deal_pipeline_stage_id = pipeline_stages.deal_pipeline_stage_id

    {% if var('hubspot_owner_enabled', true) %}
    left join owners 
        on deals.owner_id = owners.owner_id
    {% endif %}

    {% if var('hubspot_merged_deal_enabled', false) %}
    left join aggregate_merged_deals
        on deals.deal_id = aggregate_merged_deals.deal_id

    left join merged_deals
        on deals.deal_id = merged_deals.merged_deal_id
    where merged_deals.merged_deal_id is null
    {% endif %}
)   

select *
from deal_fields_joined