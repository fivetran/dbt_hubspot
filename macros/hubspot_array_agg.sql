{% macro hubspot_array_agg(field_to_agg) -%}

{{ adapter.dispatch('hubspot_array_agg', 'hubspot') (field_to_agg) }}

{%- endmacro %}

{% macro default__hubspot_array_agg(field_to_agg) %}
    array_agg({{ field_to_agg }})
{% endmacro %}

{% macro redshift__hubspot_array_agg(field_to_agg) %}
    listagg({{ field_to_agg }}, ',')
{% endmacro %}
