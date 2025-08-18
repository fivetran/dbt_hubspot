{% macro hubspot_add_pass_through_columns(base_columns, pass_through_var) %}

  {% if pass_through_var %}

    {% for column in pass_through_var %}

    {% if column is mapping %}

      {% if column.alias %}

        {% do base_columns.append({ "name": column.name, "alias": column.alias, "quote": True, "datatype": column.datatype if column.datatype else dbt.type_string()}) %}

      {% else %}

        {% do base_columns.append({ "name": column.name, "quote": True, "datatype": column.datatype if column.datatype else dbt.type_string()}) %}
        
      {% endif %}

    {% else %}

      {% do base_columns.append({ "name": column, "quote": True, "datatype": dbt.type_string()}) %}

    {% endif %}

    {% endfor %}

  {% endif %}

{% endmacro %}
