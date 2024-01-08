{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_company_enabled'])) }}

with companies as (

    select *
    from {{ var('company') }}

{% if fivetran_utils.enabled_vars(['hubspot_engagement_enabled','hubspot_engagement_company_enabled']) %}

), engagements as (

    select *
    from {{ ref('hubspot__engagements') }}

), engagement_companies as (

    select *
    from {{ var('engagement_company') }}

), engagement_companies_joined as (

    select
        engagements.engagement_type,
        engagement_companies.company_id,
        engagements.source_relation

    from engagements
    inner join engagement_companies
        on engagements.engagement_id = engagement_companies.engagement_id
        and engagements.source_relation = engagement_companies.source_relation

), engagement_companies_agg as (

    {{ engagements_aggregated('engagement_companies_joined', 'company_id') }}

), joined as (

    select 
        companies.*,
        {% for metric in engagement_metrics() %}
        coalesce(engagement_companies_agg.{{ metric }},0) as {{ metric }} {% if not loop.last %},{% endif %}
        {% endfor %}
    from companies
    left join engagement_companies_agg
        on companies.company_id = engagement_companies_agg.company_id
        and companies.source_relation = engagement_companies_agg.source_relation

)

select *
from joined

{% else %}

)

select *
from companies

{% endif %}