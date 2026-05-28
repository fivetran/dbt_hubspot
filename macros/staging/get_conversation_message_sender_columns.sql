{% macro get_conversation_message_sender_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "actor_id", "datatype": dbt.type_string()},
    {"name": "message_id", "datatype": dbt.type_string()},
    {"name": "thread_id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "sender_field", "datatype": dbt.type_string()},
    {"name": "delivery_identifier_type", "datatype": dbt.type_string()},
    {"name": "delivery_identifier_value", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}