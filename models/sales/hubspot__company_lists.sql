{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled', 'hubspot_company_list_enabled'])) }}

{% set engagements_enabled = fivetran_utils.enabled_vars(['hubspot_company_list_member_enabled', 'hubspot_engagement_enabled', 'hubspot_engagement_company_enabled']) %}

with company_lists as (

    select *
    from {{ ref('stg_hubspot__company_list') }}

{% if engagements_enabled %}

), engagement_metrics as (

    select *
    from {{ ref('int_hubspot__engagement_metrics__by_company_list') }}

{% endif %}

{% if var('hubspot_company_list_member_enabled', true) %}

), company_list_member as (

    select *
    from {{ ref('stg_hubspot__company_list_member') }}

),

company_list_members_aggregated as (
    
    select 
        source_relation,
        company_list_id,
        count(distinct company_id) as total_companies

    from company_list_member
    group by 1,2

{% endif %}

), joined as (

    select
        company_lists.*,

        {% if var('hubspot_company_list_member_enabled', true) %}
        company_list_members_aggregated.total_companies
        {% endif %}

    {% if engagements_enabled %}
        {% for metric in engagement_metrics() %}
        , coalesce(engagement_metrics.{{ metric }}, 0) as {{ metric }}
        {% endfor %}
    {% endif %}

    from company_lists

    {% if engagements_enabled %}
    left join engagement_metrics
        on company_lists.company_list_id = engagement_metrics.company_list_id
        and company_lists.source_relation = engagement_metrics.source_relation
    {% endif %}

    {% if var('hubspot_company_list_member_enabled', true) %}
    left join company_list_members_aggregated
        on company_lists.company_list_id = company_list_members_aggregated.company_list_id
        and company_lists.source_relation = company_list_members_aggregated.source_relation
    {% endif %}

)

select *
from joined
