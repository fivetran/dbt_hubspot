{% macro engagements_joined(base_model) %}

with base as (

    select *
    from {{ base_model }}

), engagements as (

    select *
    from {{ ref('hubspot__engagements') }}

), joined as (

    select 
        base.*,
        engagements.is_active,
        engagements.created_timestamp,
        engagements.occurred_timestamp,
        engagements.owner_id,
        engagements.contact_ids,
        engagements.deal_ids,
        engagements.company_ids
    from base
    left join engagements
        using (engagement_id)

)

select *
from joined

{% endmacro %}