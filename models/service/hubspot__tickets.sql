{{ config(enabled=var('hubspot_service_enabled', False)) }}

with ticket as (

    select *
    from {{ ref('stg_hubspot__ticket') }}

), ticket_pipeline as (

    select *
    from {{ ref('stg_hubspot__ticket_pipeline') }}

), ticket_pipeline_stage as (

    select *
    from {{ ref('stg_hubspot__ticket_pipeline_stage') }}

{% if var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) and var('hubspot_ticket_deal_enabled', false) %}
), ticket_deal as (

    select *
    from {{ ref('stg_hubspot__ticket_deal') }}

), deal as (

    select *
    from {{ ref('stg_hubspot__deal') }}

), join_deals as (
    
    select
        ticket_deal.source_relation,
        ticket_deal.ticket_id,
        ticket_deal.deal_id,
        deal.deal_name

    from ticket_deal
    left join deal 
        on ticket_deal.deal_id = deal.deal_id
        and ticket_deal.source_relation = deal.source_relation

), agg_deals as (

    select
        source_relation,
        ticket_id,
        {{ fivetran_utils.array_agg("case when deal_id is null then '' else cast(deal_id as " ~ dbt.type_string() ~ ") end") }} as deal_ids,
        {{ fivetran_utils.array_agg("case when deal_name is null then '' else deal_name end") }} as deal_names

    from join_deals
    group by 1,2

{% endif %}

{% if var('hubspot_sales_enabled', true) and var('hubspot_company_enabled', true) %}
), ticket_company as (

    select *
    from {{ ref('stg_hubspot__ticket_company') }}

), company as (

    select *
    from {{ ref('stg_hubspot__company') }}

), join_companies as (
    
    select
        ticket_company.source_relation,
        ticket_company.ticket_id,
        ticket_company.company_id,
        company.company_name

    from ticket_company
    left join company 
        on ticket_company.company_id = company.company_id
        and ticket_company.source_relation = company.source_relation

), agg_companies as (

    select
        source_relation,
        ticket_id,
        {{ fivetran_utils.array_agg("case when company_id is null then '' else cast(company_id as " ~ dbt.type_string() ~ ") end") }} as company_ids,
        {{ fivetran_utils.array_agg("case when company_name is null then '' else company_name end") }} as company_names

    from join_companies
    group by 1,2

{% endif %}

{% if var('hubspot_marketing_enabled', true) and var('hubspot_contact_enabled', true) %}
), ticket_contact as (

    select *
    from {{ ref('stg_hubspot__ticket_contact') }}

), contact as (

    select *
    from {{ ref('stg_hubspot__contact') }}

), join_contacts as (
    
    select
        ticket_contact.source_relation,
        ticket_contact.ticket_id,
        ticket_contact.contact_id,
        contact.email

    from ticket_contact
    left join contact 
        on ticket_contact.contact_id = contact.contact_id
        and ticket_contact.source_relation = contact.source_relation

), agg_contacts as (

    select
        source_relation,
        ticket_id,
        {{ fivetran_utils.array_agg("case when contact_id is null then '' else cast(contact_id as " ~ dbt.type_string() ~ ") end") }} as contact_ids,
        {{ fivetran_utils.array_agg("case when email is null then '' else email end") }} as contact_emails

    from join_contacts
    group by 1,2

{% endif %}

{% if var('hubspot_owner_enabled', true) %}
), owners_enhanced as (

    select *
    from {{ ref('int_hubspot__owners_enhanced') }}

{% endif%}

{% if var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) %}
), engagement as (

    select *
    from {{ ref('hubspot__engagements') }}

), ticket_engagement as (

    select *
    from {{ ref('stg_hubspot__ticket_engagement') }}

), join_engagements as (

    select 
        engagement.source_relation,
        engagement.engagement_type,
        ticket_engagement.ticket_id
    from engagement
    inner join ticket_engagement
        on cast(engagement.engagement_id as {{ dbt.type_bigint() }}) = cast(ticket_engagement.engagement_id as {{ dbt.type_bigint() }} )
        and engagement.source_relation = ticket_engagement.source_relation

), agg_engagements as (

    {{ engagements_aggregated('join_engagements', 'ticket_id') }}

{% endif %}

), final_join as (

    select
        ticket.*,
        ticket_pipeline_stage.ticket_state,
        ticket_pipeline_stage.is_closed,
        ticket_pipeline_stage.pipeline_stage_label,
        ticket_pipeline.pipeline_label,
        ticket_pipeline_stage.display_order as pipeline_stage_order,
        ticket_pipeline.is_ticket_pipeline_deleted,
        ticket_pipeline_stage.is_ticket_pipeline_stage_deleted

    {% if var('hubspot_owner_enabled', true) %}
        , {{ dbt_utils.star(ref('int_hubspot__owners_enhanced'), except=["owner_id", "source_relation"], relation_alias="owners_enhanced") }}
    {% endif %}

    {% if var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) and var('hubspot_ticket_deal_enabled', false) %}
        , agg_deals.deal_ids
        , agg_deals.deal_names
    {% endif %}

    {% if var('hubspot_marketing_enabled', true) and var('hubspot_contact_enabled', true) %}
        , agg_contacts.contact_ids
        , agg_contacts.contact_emails
    {% endif %}

    {% if var('hubspot_sales_enabled', true) and var('hubspot_company_enabled', true) %}
        , agg_companies.company_ids
        , agg_companies.company_names
    {% endif %}

    {% if var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) %}
        {% for metric in engagement_metrics() %}
        , coalesce(agg_engagements.{{ metric }},0) as {{ metric }}
        {% endfor %}
    {% endif %}

    from ticket

    left join ticket_pipeline 
        on cast(ticket.ticket_pipeline_id as {{ dbt.type_string() }}) = cast(ticket_pipeline.ticket_pipeline_id as {{ dbt.type_string() }})
        and ticket.source_relation = ticket_pipeline.source_relation
    
    left join ticket_pipeline_stage 
        on cast(ticket.ticket_pipeline_stage_id as {{ dbt.type_string() }}) = cast(ticket_pipeline_stage.ticket_pipeline_stage_id as {{ dbt.type_string() }})
        and cast(ticket_pipeline.ticket_pipeline_id as {{ dbt.type_string() }}) = cast(ticket_pipeline_stage.ticket_pipeline_id as {{ dbt.type_string() }})
        and ticket.source_relation = ticket_pipeline_stage.source_relation

    {% if var('hubspot_owner_enabled', true) %}
    left join owners_enhanced 
        on ticket.owner_id = owners_enhanced.owner_id
        and ticket.source_relation = owners_enhanced.source_relation
    {% endif %}

    {% if var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) and var('hubspot_ticket_deal_enabled', false) %}
    left join agg_deals 
        on ticket.ticket_id = agg_deals.ticket_id
        and ticket.source_relation = agg_deals.source_relation
    {% endif %}

    {% if var('hubspot_marketing_enabled', true) and var('hubspot_contact_enabled', true) %}
    left join agg_contacts
        on ticket.ticket_id = agg_contacts.ticket_id 
        and ticket.source_relation = agg_contacts.source_relation
    {% endif %}

    {% if var('hubspot_sales_enabled', true) and var('hubspot_company_enabled', true) %}
    left join agg_companies
        on ticket.ticket_id = agg_companies.ticket_id 
        and ticket.source_relation = agg_companies.source_relation
    {% endif %}

    {% if var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) %}
    left join agg_engagements
        on ticket.ticket_id = agg_engagements.ticket_id
        and ticket.source_relation = agg_engagements.source_relation
    {% endif %}
)

select *
from final_join