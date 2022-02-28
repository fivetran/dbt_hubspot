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
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_contact_enabled']) %} engagements.contact_ids, {% endif %}
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_deal_enabled']) %} engagements.deal_ids, {% endif %}
        {% if fivetran_utils.enabled_vars(['hubspot_engagement_company_enabled']) %} engagements.company_ids, {% endif %}
        engagements.is_active,
        engagements.created_timestamp,
        engagements.occurred_timestamp,
        engagements.owner_id
    from base
    left join engagements
        using (engagement_id)

)

select *
from joined

{% endmacro %}