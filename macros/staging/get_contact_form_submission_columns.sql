{% macro get_contact_form_submission_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "timestamp", "datatype": dbt.type_timestamp()},
    {"name": "form_id", "datatype": dbt.type_bigint()},
    {"name": "contact_id", "datatype": dbt.type_bigint()},
    {"name": "conversion_id", "datatype": dbt.type_bigint()},
    {"name": "page_id", "datatype": dbt.type_bigint()},
    {"name": "page_url", "datatype": dbt.type_string()},
    {"name": "portal_id", "datatype": dbt.type_int()},
    {"name": "title", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}