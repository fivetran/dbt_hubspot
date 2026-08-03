{{ config(enabled=fivetran_utils.enabled_vars([
    'hubspot_sales_enabled',
    'hubspot_company_list_member_enabled',
    'hubspot_engagement_enabled',
    'hubspot_engagement_company_enabled'
])) }}

with company_list_member as (

    select *
    from {{ ref('stg_hubspot__company_list_member') }}
    where not coalesce(is_company_list_member_deleted, false)

), engagements as (

    select *
    from {{ ref('hubspot__engagements') }}

), engagement_companies as (

    select *
    from {{ ref('stg_hubspot__engagement_company') }}

), engagement_companies_joined as (

    select
        engagements.engagement_type,
        engagement_companies.company_id,
        engagement_companies.source_relation
    from engagements
    join engagement_companies
        on engagements.engagement_id = engagement_companies.engagement_id
        and engagements.source_relation = engagement_companies.source_relation

), company_list_engagements as (

    select
        company_list_member.company_list_id,
        company_list_member.source_relation,
        engagement_companies_joined.engagement_type
    from company_list_member
    join engagement_companies_joined
        on company_list_member.company_id = engagement_companies_joined.company_id
        and company_list_member.source_relation = engagement_companies_joined.source_relation

), engagement_metrics as (

    {{ engagements_aggregated('company_list_engagements', 'company_list_id') }}

)

select *
from engagement_metrics
