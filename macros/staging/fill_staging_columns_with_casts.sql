{% macro fill_staging_columns_with_casts(source_columns, staging_columns, cast_columns=[]) %}

{#- Same output as fivetran_utils.fill_staging_columns, except that the columns named in
    cast_columns (by their output name) are cast to their declared datatype. This keeps
    column types the same whether or not hubspot__pass_through_all_columns is enabled. -#}

{%- set source_column_names = source_columns|map(attribute='name')|map('lower')|list -%}
{%- set using_source_casing = var('fivetran_using_source_casing', false) -%}
{%- set cast_column_names = cast_columns|map('lower')|list -%}

{%- for column in staging_columns %}
    {%- set column_alias = column.alias if 'alias' in column else column.name %}
    {%- if column_alias|lower in cast_column_names %}
        {%- if column.name|lower not in source_column_names %}
            {%- set column_expression = 'null' %}
        {%- elif using_source_casing %}
            {%- set column_expression = adapter.quote(column.name) %}
        {%- else %}
            {%- set column_expression = fivetran_utils.quote_column(column) %}
        {%- endif %}
        {%- if using_source_casing %}
            cast({{ column_expression }} as {{ column.datatype }}) as {{ adapter.quote(column_alias|upper if target.type == 'snowflake' else column_alias) }}
        {%- else %}
            cast({{ column_expression }} as {{ column.datatype }}) as {% if 'alias' in column %}{{ column.alias }}{% else %}{{ fivetran_utils.quote_column(column) }}{% endif %}
        {%- endif %}
    {%- else %}
        {{ fivetran_utils.fill_staging_columns(source_columns=source_columns, staging_columns=[column]) }}
    {%- endif %}{{ ',' if not loop.last }}
{%- endfor %}

{%- endmacro %}
