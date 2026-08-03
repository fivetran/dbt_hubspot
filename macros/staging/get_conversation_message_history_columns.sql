{% macro get_conversation_message_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "thread_id", "datatype": dbt.type_string()},
    {"name": "channel_account_id", "datatype": dbt.type_string()},
    {"name": "channel_id", "datatype": dbt.type_string()},
    {"name": "from_inbox_id", "datatype": dbt.type_string()},
    {"name": "to_inbox_id", "datatype": dbt.type_string()},
    {"name": "assigned_to", "datatype": dbt.type_string()},
    {"name": "assigned_from", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "created_by", "datatype": dbt.type_string()},
    {"name": "direction", "datatype": dbt.type_string()},
    {"name": "in_reply_to_id", "datatype": dbt.type_string()},
    {"name": "new_status", "datatype": dbt.type_string()},
    {"name": "rich_text", "datatype": dbt.type_string()},
    {"name": "subject", "datatype": dbt.type_string()},
    {"name": "text", "datatype": dbt.type_string()},
    {"name": "truncation_status", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "client_type", "datatype": dbt.type_string()},
    {"name": "status_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}