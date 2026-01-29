{% macro get_engagement_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "portal_id", "datatype": dbt.type_int()},
    {"name": "type", "datatype": dbt.type_string(), "alias": "engagement_type"}
] %}

{{ return(columns) }}

{% endmacro %}
