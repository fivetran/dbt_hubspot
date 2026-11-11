{% macro engagements_joined(base_model) %}

with base as (

    select *
    from {{ base_model }}

), engagements as (

    select *
    from {{ ref('hubspot__engagements') }}

), joined as (

    select
        {{ dbt_utils.star(from=base_model, relation_alias="base", except=["_fivetran_deleted"]) }},
        {% if var('hubspot_engagement_contact_enabled', true) %} engagements.contact_ids, {% endif %}
        {% if var('hubspot_engagement_deal_enabled', true) %} engagements.deal_ids, {% endif %}
        {% if var('hubspot_engagement_company_enabled', true) %} engagements.company_ids, {% endif %}
        not base._fivetran_deleted as is_active
    from base
    left join engagements
        on base.engagement_id = engagements.engagement_id
        and base.source_relation = engagements.source_relation

)

select *
from joined

{% endmacro %}