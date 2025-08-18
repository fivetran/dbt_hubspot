{% macro get_form_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "guid", "datatype": dbt.type_bigint()},
    {"name": "action", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "css_class", "datatype": dbt.type_string()},
    {"name": "follow_up_id", "datatype": dbt.type_bigint()},
    {"name": "form_type", "datatype": dbt.type_string()},
    {"name": "lead_nurturing_campaign_id", "datatype": dbt.type_bigint()},
    {"name": "method", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "notify_recipients", "datatype": dbt.type_boolean()},
    {"name": "portal_id", "datatype": dbt.type_int()},
    {"name": "redirect", "datatype": dbt.type_string()},
    {"name": "submit_text", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}