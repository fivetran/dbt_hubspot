{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'hubspot') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('hubspot_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("hubspot_database", target.database) }}' || '.'|| '{{ var("hubspot_schema", "hubspot") }}' as source_relation
{% endif %}

{%- endmacro %}