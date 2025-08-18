{% macro get_users_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "primary_team_id", "datatype": dbt.type_int()},
    {"name": "role_id", "datatype": dbt.type_int()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
