{% macro get_engagement_company_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "company_id", "datatype": dbt.type_int()},
    {"name": "engagement_id", "datatype": dbt.type_int()},
    {"name": "category", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
