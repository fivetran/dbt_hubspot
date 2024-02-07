{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled','hubspot_engagement_contact_enabled'])) }}

with engagements as (

    select *
    from {{ ref('hubspot__engagements') }}

), engagement_contacts as (

    select *
    from {{ var('engagement_contact') }}

), engagement_contacts_joined as (

    select
        engagements.engagement_type,
        engagement_contacts.contact_id,
        engagements.source_relation
        
    from engagements
    inner join engagement_contacts
        on engagements.engagement_id = engagement_contacts.engagement_id
        and engagements.source_relation = engagement_contacts.source_relation

), engagement_contacts_agg as (

    {{ engagements_aggregated('engagement_contacts_joined', 'contact_id') }}

)

select *
from engagement_contacts_agg