
{% macro get_team_user_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "team_id", "datatype": dbt.type_int()},
    {"name": "user_id", "datatype": dbt.type_int()},
    {"name": "is_secondary_user", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}
