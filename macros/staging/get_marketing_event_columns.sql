{% macro get_marketing_event_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "app_id", "datatype": dbt.type_string()},
    {"name": "app_name", "datatype": dbt.type_string()},
    {"name": "attendees", "datatype": dbt.type_int()},
    {"name": "cancellations", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "end_date_time", "datatype": dbt.type_timestamp()},
    {"name": "event_cancelled", "datatype": "boolean"},
    {"name": "event_completed", "datatype": "boolean"},
    {"name": "event_description", "datatype": dbt.type_string()},
    {"name": "event_name", "datatype": dbt.type_string()},
    {"name": "event_organizer", "datatype": dbt.type_string()},
    {"name": "event_status", "datatype": dbt.type_string()},
    {"name": "event_type", "datatype": dbt.type_string()},
    {"name": "event_url", "datatype": dbt.type_string()},
    {"name": "external_event_id", "datatype": dbt.type_string()},
    {"name": "no_shows", "datatype": dbt.type_int()},
    {"name": "registrants", "datatype": dbt.type_int()},
    {"name": "start_date_time", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
