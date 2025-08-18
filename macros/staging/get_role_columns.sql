{% macro get_role_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "requires_billing_write", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}
