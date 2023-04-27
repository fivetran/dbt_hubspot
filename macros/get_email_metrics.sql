{% macro get_email_metrics(base_ref, var_name) %}

{# Get cols of base table #}
{% set base_cols = adapter.get_columns_in_relation(ref(base_ref))|map(attribute='name')|map('lower')|list %}

{# Set cols of metrics to compare against base #}
{% if var(var_name, None) %}
    {% set email_metrics = var(var_name) %}
{% else %}
    {% set email_metrics = ['bounces', 'clicks', 'deferrals', 'deliveries', 'drops', 
        'forwards', 'opens', 'prints', 'spam_reports', 'unsubscribes'] %}
{% endif %}

{# Remove metrics not in base #}
{% for metric in email_metrics %}
    {% if metric|lower not in base_cols %}
        {% do email_metrics.remove(metric) %}
    {% endif %}
{% endfor %}

{{ return(email_metrics) }}

{% endmacro %}