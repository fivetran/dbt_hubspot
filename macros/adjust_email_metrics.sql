{% macro adjust_email_metrics(base_ref, var_name) %}

{% set base_cols = adapter.get_columns_in_relation(ref(base_ref))|map(attribute='name')|map('lower')|list %}
{% set email_metrics = var(var_name) %}

{# Remove metrics not in base #}
{% set new_cols = [] %}
{% for metric in email_metrics %}
    {% if metric|lower in base_cols %}
        {% do new_cols.append(metric) %}
    {% endif %}
{% endfor %}

{{ return(new_cols) }}

{% endmacro %}