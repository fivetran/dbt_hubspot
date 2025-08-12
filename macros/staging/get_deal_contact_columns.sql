{% macro get_deal_contact_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "deal_id", "datatype": dbt.type_int()},
    {"name": "contact_id", "datatype": dbt.type_int()},
    {"name": "type_id", "datatype": dbt.type_int()},
    {"name": "category", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
