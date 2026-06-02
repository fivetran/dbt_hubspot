{% macro all_passthrough_column_check(source_columns, get_columns) %}

{% set available_passthrough_columns = fivetran_utils.remove_prefix_from_columns(
                columns=source_columns, 
                prefix='property_', exclude=get_macro_columns(get_columns)) 
            %}

{{ return(available_passthrough_columns|length) }}

{% endmacro %}