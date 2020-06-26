{% macro array_agg(field_to_agg) -%}

{{ adapter_macro('hubspot.array_agg', field_to_agg) }}

{%- endmacro %}

{% macro default__array_agg(field_to_agg) %}
    array_agg({{ field_to_agg }})
{% endmacro %}

{% macro redshift__array_agg(field_to_agg) %}
    listagg({{ field_to_agg }}, ',')
{% endmacro %}

{% macro postgres__array_agg(field_to_agg) %}
    string_agg({{ field_to_agg }}, ',')
{% endmacro %}