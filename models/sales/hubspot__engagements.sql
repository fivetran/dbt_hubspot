{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled'])) }}

with engagements as (

    select *
    from {{ var('engagement') }}

{% if fivetran_utils.enabled_vars(['hubspot_engagement_contact_enabled']) %}

), contacts as (

    select *
    from {{ var('engagement_contact') }}

), contacts_agg as (

    select 
        engagement_id,
        source_relation,
        {{ fivetran_utils.array_agg('contact_id') }} as contact_ids
    from contacts
    group by 1,2

{% endif %}

{% if fivetran_utils.enabled_vars(['hubspot_engagement_deal_enabled']) %}

), deals as (

    select *
    from {{ var('engagement_deal') }}
 
), deals_agg as (

    select 
        engagement_id,
        source_relation,
        {{ fivetran_utils.array_agg('deal_id') }} as deal_ids
    from deals
    group by 1,2

{% endif %}

{% if fivetran_utils.enabled_vars(['hubspot_engagement_company_enabled']) %}

), companies as (

    select *
    from {{ var('engagement_company') }}

), companies_agg as (

    select 
        engagement_id,
        source_relation,
        {{ fivetran_utils.array_agg('company_id') }} as company_ids
    from companies
    group by 1,2

{% endif %}

), joined as (

    select 
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_contact_enabled']) %} contacts_agg.contact_ids, {% endif %}
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_deal_enabled']) %} deals_agg.deal_ids, {% endif %}
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_company_enabled']) %} companies_agg.company_ids, {% endif %}
        engagements.*
    from engagements
    {% if fivetran_utils.enabled_vars(['hubspot_engagement_contact_enabled']) %} 
    left join contacts_agg 
        on engagements.engagement_id = contacts_agg.engagement_id 
        and engagements.source_relation = contacts_agg.source_relation 
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_engagement_deal_enabled']) %} 
    left join deals_agg 
        on engagements.engagement_id = deals_agg.engagement_id 
        and engagements.source_relation = deals_agg.source_relation 
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_engagement_company_enabled']) %} 
        left join companies_agg 
            on engagements.engagement_id = companies_agg.engagement_id 
            and engagements.source_relation = companies_agg.source_relation 
    {% endif %}
)

select *
from joined