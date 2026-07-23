{% macro get_marketing_event_list_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "marketing_event_id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "updated_by_id", "datatype": dbt.type_string()},
    {"name": "filters_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "processing_status", "datatype": dbt.type_string()},
    {"name": "deleted_at", "datatype": dbt.type_timestamp()},
    {"name": "list_version", "datatype": dbt.type_int()},
    {"name": "object_type_id", "datatype": dbt.type_string()},
    {"name": "size", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
