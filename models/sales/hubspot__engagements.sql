{{ config(enabled=(var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true))) }}

with engagements as (

    select *
    from {{ ref('stg_hubspot__engagement') }}

{% if var('hubspot_engagement_contact_enabled', true) %}

), contacts as (

    select *
    from {{ ref('stg_hubspot__engagement_contact') }}

), contacts_agg as (

    select
        source_relation,
        engagement_id,
        {{ hubspot_array_agg('contact_id') }} as contact_ids
    from contacts
    group by 1, 2

{% endif %}

{% if var('hubspot_engagement_deal_enabled', true) %}

), deals as (

    select *
    from {{ ref('stg_hubspot__engagement_deal') }}
 
), deals_agg as (

    select
        source_relation,
        engagement_id,
        {{ hubspot_array_agg('deal_id') }} as deal_ids
    from deals
    group by 1, 2

{% endif %}

{% if var('hubspot_engagement_company_enabled', true) %}

), companies as (

    select *
    from {{ ref('stg_hubspot__engagement_company') }}

), companies_agg as (

    select
        source_relation,
        engagement_id,
        {{ hubspot_array_agg('company_id') }} as company_ids
    from companies
    group by 1, 2

{% endif %}

), joined as (

    select 
        {% if var('hubspot_engagement_contact_enabled', true) %} contacts_agg.contact_ids, {% endif %}
        {% if var('hubspot_engagement_deal_enabled', true) %} deals_agg.deal_ids, {% endif %}
        {% if var('hubspot_engagement_company_enabled', true) %} companies_agg.company_ids, {% endif %}
        engagements.*
    from engagements
    {% if var('hubspot_engagement_contact_enabled', true) %}
    left join contacts_agg
        on engagements.engagement_id = contacts_agg.engagement_id
        and engagements.source_relation = contacts_agg.source_relation
    {% endif %}
    {% if var('hubspot_engagement_deal_enabled', true) %}
    left join deals_agg
        on engagements.engagement_id = deals_agg.engagement_id
        and engagements.source_relation = deals_agg.source_relation
    {% endif %}
    {% if var('hubspot_engagement_company_enabled', true) %}
    left join companies_agg
        on engagements.engagement_id = companies_agg.engagement_id
        and engagements.source_relation = companies_agg.source_relation
    {% endif %}

)

select *
from joined