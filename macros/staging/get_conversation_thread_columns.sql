{% macro get_conversation_thread_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "inbox_id", "datatype": dbt.type_string()},
    {"name": "associated_contact_id", "datatype": dbt.type_string()},
    {"name": "associated_ticket_id", "datatype": dbt.type_string()},
    {"name": "original_channel_account_id", "datatype": dbt.type_string()},
    {"name": "original_channel_id", "datatype": dbt.type_string()},
    {"name": "assigned_to", "datatype": dbt.type_string()},
    {"name": "closed_at", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "latest_message_received_timestamp", "datatype": dbt.type_timestamp()},
    {"name": "latest_message_sent_timestamp", "datatype": dbt.type_timestamp()},
    {"name": "latest_message_timestamp", "datatype": dbt.type_timestamp()},
    {"name": "spam", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
