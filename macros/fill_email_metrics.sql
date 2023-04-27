{%- macro fill_email_metrics(base_ref) %}

{%- set base_cols = adapter.get_columns_in_relation(ref(base_ref))|map(attribute='name')|map('lower')|list -%}

{%- if var(email_metrics_var, None) %}
    {%- set email_metrics = var(email_metrics_var) %}
{%- else %}
    {%- set email_metrics = ['bounces', 'clicks', 'deferrals', 'deliveries', 'drops', 
        'forwards', 'opens', 'prints', 'spam_reports', 'unsubscribes'] %}
{%- endif %}

{%- for metric in email_metrics %}
    {%- if metric|lower not in base_cols -%}
        , cast(null as {{ dbt.type_int() }}) as {{ metric }}
    {%- endif -%} 
{%- endfor %}

{%- endmacro %}