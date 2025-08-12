{% macro get_owner_team_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "owner_id", "datatype": dbt.type_int()},
    {"name": "team_id", "datatype": dbt.type_int()},
    {"name": "is_team_primary", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}
