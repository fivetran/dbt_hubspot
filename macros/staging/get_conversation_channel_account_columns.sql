{% macro get_conversation_channel_account_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "channel_id", "datatype": dbt.type_string()},
    {"name": "inbox_id", "datatype": dbt.type_string()},
    {"name": "active", "datatype": dbt.type_boolean()},
    {"name": "authorized", "datatype": dbt.type_boolean()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "delivery_identifier_type", "datatype": dbt.type_string()},
    {"name": "delivery_identifier_value", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
