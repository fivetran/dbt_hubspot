{{ config(enabled=var('hubspot_marketing_enabled', true) and var('hubspot_marketing_event_enabled', true)) }}

with marketing_events as (

    select *
    from {{ ref('stg_hubspot__marketing_event') }}

{% if var('hubspot_marketing_event_participant_enabled', true) %}

), participants_agg as (

    select
        source_relation,
        marketing_event_id,
        count(distinct contact_id)                                                                    as total_contacts,
        count(distinct case when attendance_state = 'ATTENDED'   then contact_id end)                 as total_attended_contacts,
        count(distinct case when attendance_state = 'CANCELLED'  then contact_id end)                 as total_cancelled_contacts,
        count(distinct case when attendance_state = 'EMPTY'      then contact_id end)                 as total_empty_contacts,
        count(distinct case when attendance_state = 'NO_SHOW'    then contact_id end)                 as total_no_show_contacts,
        count(distinct case when attendance_state = 'REGISTERED' then contact_id end)                 as total_registered_contacts,
        avg(attendance_duration_seconds)                                                              as avg_attendance_duration_seconds
    from {{ ref('stg_hubspot__marketing_event_participant') }}
    group by 1, 2

{% endif %}

{% if var('hubspot_marketing_event_list_enabled', true) %}

), lists_agg as (

    select
        source_relation,
        marketing_event_id,
        count(marketing_event_list_id) as total_lists
    from {{ ref('stg_hubspot__marketing_event_list') }}
    where deleted_timestamp is null
    group by 1, 2

{% endif %}

{% set custom_property_columns = var('hubspot_marketing_event_custom_properties', []) %}

{% if var('hubspot_marketing_event_custom_property_enabled', true) and custom_property_columns != [] %}

), custom_properties as (

    select
        source_relation,
        marketing_event_id
        {% for column in custom_property_columns %}
        , max(case when property_name = '{{ column }}' then property_value end) as property_{{ column }}
        {% endfor %}
    from {{ ref('stg_hubspot__marketing_event_custom_property') }}
    group by 1, 2

{% endif %}

), joined as (

    select
        marketing_events.*,

        -- Derived time and rate metrics
        {{ dbt.datediff("marketing_events.start_timestamp", "marketing_events.end_timestamp", "minute") }} as event_duration_minutes,

        case when coalesce(marketing_events.registrants, 0) > 0
            then cast(marketing_events.attendees as {{ dbt.type_numeric() }}) / marketing_events.registrants
        end as attendance_rate,

        case when coalesce(marketing_events.registrants, 0) > 0
            then cast(marketing_events.no_shows as {{ dbt.type_numeric() }}) / marketing_events.registrants
        end as no_show_rate,

        case when coalesce(marketing_events.registrants, 0) > 0
            then cast(marketing_events.cancellations as {{ dbt.type_numeric() }}) / marketing_events.registrants
        end as cancellation_rate

        {% if var('hubspot_marketing_event_participant_enabled', true) %}
        , participants_agg.total_contacts
        , participants_agg.total_attended_contacts
        , participants_agg.total_cancelled_contacts
        , participants_agg.total_empty_contacts
        , participants_agg.total_no_show_contacts
        , participants_agg.total_registered_contacts
        , participants_agg.avg_attendance_duration_seconds
        {% endif %}

        {% if var('hubspot_marketing_event_list_enabled', true) %}
        , coalesce(lists_agg.total_lists, 0) as total_lists
        {% endif %}

        {% if var('hubspot_marketing_event_custom_property_enabled', true) and custom_property_columns != [] %}
        {% for column in custom_property_columns %}
        , custom_properties.property_{{ column }}
        {% endfor %}
        {% endif %}

    from marketing_events

    {% if var('hubspot_marketing_event_participant_enabled', true) %}
    left join participants_agg
        on marketing_events.marketing_event_id = participants_agg.marketing_event_id
        and marketing_events.source_relation = participants_agg.source_relation
    {% endif %}

    {% if var('hubspot_marketing_event_list_enabled', true) %}
    left join lists_agg
        on marketing_events.marketing_event_id = lists_agg.marketing_event_id
        and marketing_events.source_relation = lists_agg.source_relation
    {% endif %}

    {% if var('hubspot_marketing_event_custom_property_enabled', true) and custom_property_columns != [] %}
    left join custom_properties
        on marketing_events.marketing_event_id = custom_properties.marketing_event_id
        and marketing_events.source_relation = custom_properties.source_relation
    {% endif %}

)

select *
from joined
