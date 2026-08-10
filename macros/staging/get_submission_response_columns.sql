{% macro get_submission_response_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "conversion_id", "datatype": dbt.type_string()},
    {"name": "form_id", "datatype": dbt.type_string()},
    {"name": "field_name", "datatype": dbt.type_string()},
    {"name": "field_value", "datatype": dbt.type_string()},
    {"name": "submitted_at", "datatype": dbt.type_bigint()},
    {"name": "page_url", "datatype": dbt.type_string()},
    {"name": "object_type_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
