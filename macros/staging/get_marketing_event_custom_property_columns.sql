{% macro get_marketing_event_custom_property_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "marketing_event_id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "value", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
