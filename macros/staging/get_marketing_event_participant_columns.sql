{% macro get_marketing_event_participant_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "marketing_event_id", "datatype": dbt.type_int()},
    {"name": "contact_id", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "properties_occurred_at", "datatype": dbt.type_timestamp()},
    {"name": "properties_attendance_percentage", "datatype": dbt.type_numeric()},
    {"name": "properties_attendance_state", "datatype": dbt.type_string()},
    {"name": "properties_attendance_duration_seconds", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
