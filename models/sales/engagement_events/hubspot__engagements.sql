with engagements as (

    select *
    from {{ var('engagement') }}

), contacts as (

    select *
    from {{ var('engagement_contact') }}

), companies as (

    select *
    from {{ var('engagement_company') }}

), deals as (

    select *
    from {{ var('engagement_deal') }}

), contacts_agg as (

    select 
        engagement_id,
        array_agg(contact_id) as contact_ids
    from contacts
    group by 1

), deals_agg as (

    select 
        engagement_id,
        array_agg(deal_id) as deal_ids
    from deals
    group by 1

), companies_agg as (

    select 
        engagement_id,
        array_agg(company_id) as company_ids
    from companies
    group by 1

), joined as (

    select 
        engagements.*,
        contacts_agg.contact_ids,
        deals_agg.deal_ids,
        companies_agg.company_ids
    from engagements
    left join contacts_agg using (engagement_id)
    left join deals_agg using (engagement_id)
    left join companies_agg using (engagement_id)

)

select *
from joined