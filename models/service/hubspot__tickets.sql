{{ config(enabled=var('hubspot_service_enabled', False)) }}

with ticket as (

    select *
    from {{ var('ticket') }}

), ticket_pipeline as (

    select *
    from {{ var('ticket_pipeline') }}

), ticket_pipeline_stage as (

    select *
    from {{ var('ticket_pipeline_stage') }}

{% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_ticket_deal_enabled']) %}
), ticket_deal as (

    select *
    from {{ var('ticket_deal') }}

), deal as (

    select *
    from {{ var('deal') }}

), join_deals as (
    
    select
        ticket_deal.ticket_id,
        ticket_deal.deal_id,
        deal.deal_name
        -- would grab `deal.amount` but the currency could be different per deal 

    from ticket_deal
    left join deal 
        on ticket_deal.deal_id = deal.deal_id

), agg_deals as (

    select
        ticket_id,
        -- should we use string_agg? i opted for array bc that's what we used msotly in this package, but we'd need to adjust the array_agg macro in fivetran_utils to ignore nulls 
        -- or i can add an ifnull(deal_id, empty string '')
        {{ fivetran_utils.array_agg("deal_id") }} as deal_ids,
        {{ fivetran_utils.array_agg("deal_name") }} as deal_names

    from join_deals
    group by 1

{% endif %}

{% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_company_enabled']) %}
), ticket_company as (

    select *
    from {{ var('ticket_company') }}

), company as (

    select *
    from {{ var('company') }}

), join_companies as (
    
    select
        ticket_company.ticket_id,
        ticket_company.company_id,
        company.company_name

    from ticket_company
    left join company 
        on ticket_company.company_id = company.company_id

), agg_companies as (

    select
        ticket_id,
        {{ fivetran_utils.array_agg("company_id") }} as company_ids,
        {{ fivetran_utils.array_agg("company_name") }} as company_names

    from join_companies
    group by 1

{% endif %}

{% if fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled']) %}
), ticket_contact as (

    select *
    from {{ var('ticket_contact') }}

), contact as (

    select *
    from {{ var('contact') }}

), join_contacts as (
    
    select
        ticket_contact.ticket_id,
        ticket_contact.contact_id,
        contact.email

    from ticket_contact
    left join contact 
        on ticket_contact.contact_id = contact.contact_id

), agg_contacts as (

    select
        ticket_id,
        {{ fivetran_utils.array_agg("contact_id") }} as contact_ids,
        {{ fivetran_utils.array_agg("email") }} as contact_emails

    from join_contacts
    group by 1

{% endif %}

{% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_owner_enabled']) %}
), owner as (

    select *
    from {{ var('owner') }}

{% endif%}

{% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled']) %}
), engagement as (

    select *
    from {{ ref('hubspot__engagements') }}

), ticket_engagement as (

    select *
    from {{ var('ticket_engagement') }}

), join_engagements as (

    select 
        engagement.engagement_type,
        ticket_engagement.ticket_id
    from engagement
    inner join ticket_engagement
        on cast(engagement.engagement_id as {{ dbt.type_bigint() }}) = cast(ticket_engagement.engagement_id as {{ dbt.type_bigint() }} )

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

    {% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_owner_enabled']) %}
        , owner.email_address as owner_email
        , owner.full_name as owner_full_name
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_ticket_deal_enabled']) %}
        , agg_deals.deal_ids
        , agg_deals.deal_names
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled']) %}
        , agg_contacts.contact_ids
        , agg_contacts.contact_emails
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_company_enabled']) %}
        , agg_companies.company_ids
        , agg_companies.company_names
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled']) %}
        {% for metric in engagement_metrics() %}
        , coalesce(agg_engagements.{{ metric }},0) as {{ metric }}
        {% endfor %}
    {% endif %}

    from ticket

    left join ticket_pipeline 
        on ticket.ticket_pipeline_id = ticket_pipeline.ticket_pipeline_id 
    
    left join ticket_pipeline_stage 
        on ticket.ticket_pipeline_stage_id = ticket_pipeline_stage.ticket_pipeline_stage_id
        and ticket_pipeline.ticket_pipeline_id = ticket_pipeline_stage.ticket_pipeline_id

    {% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_owner_enabled']) %}
    left join owner 
        on ticket.owner_id = owner.owner_id
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_deal_enabled','hubspot_ticket_deal_enabled']) %}
    left join agg_deals 
        on ticket.ticket_id = agg_deals.ticket_id
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled']) %}
    left join agg_contacts
        on ticket.ticket_id = agg_contacts.ticket_id 
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_company_enabled']) %}
    left join agg_companies
        on ticket.ticket_id = agg_companies.ticket_id 
    {% endif %}

    {% if fivetran_utils.enabled_vars(['hubspot_sales_enabled','hubspot_engagement_enabled']) %}
    left join agg_engagements
        on ticket.ticket_id = agg_engagements.ticket_id
    {% endif %}
)

select *
from final_join