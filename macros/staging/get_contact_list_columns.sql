{% macro get_contact_list_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean", "alias": "is_contact_list_deleted"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp(), "alias": "created_timestamp"},
    {"name": "id", "datatype": dbt.type_int(), "alias": "contact_list_id"},
    {"name": "name", "datatype": dbt.type_string(), "alias": "contact_list_name"},
    {"name": "updated_at", "datatype": dbt.type_timestamp(), "alias": "updated_timestamp"},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "filters_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "list_version", "datatype": dbt.type_int()},
    {"name": "object_type_id", "datatype": dbt.type_string()},
    {"name": "processing_status", "datatype": dbt.type_string()},
    {"name": "processing_type", "datatype": dbt.type_string()},
    {"name": "deleteable", "datatype": "boolean"},
    {"name": "dynamic", "datatype": "boolean"},
    {"name": "portal_id", "datatype": dbt.type_int()},
    {"name": "metadata_error", "datatype": dbt.type_string()},
    {"name": "metadata_last_processing_state_change_at", "datatype": dbt.type_timestamp()},
    {"name": "metadata_last_size_change_at", "datatype": dbt.type_timestamp()},
    {"name": "metadata_processing", "datatype": dbt.type_string()},
    {"name": "metadata_size", "datatype": dbt.type_int()}
] %}

{{ hubspot_add_pass_through_columns(columns, var('hubspot__contact_list_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
