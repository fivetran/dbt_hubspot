{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled'])) }}

with contacts as (

    select *
    from {{ var('contact') }}

{% if target.type == 'bigquery' or var('hubspot_contact_merge_audit_enabled', false) %}
), contact_merge_audit as (
    select *
    from {{ var('contact_merge_audit') }}

{% else %}

{% if target.type == 'redshift' %}
/*
Unfortunately, `email_list_ids` are brought in as a JSON ARRAY, which different destinations handle completely differently. 
The below code serves to extract and pivot merged vids into individual rows. 
We are making the assumption that a user will not have more than 1000 merges into one contact. If that's wrong please open an issue!
https://github.com/fivetran/dbt_iterable/issues/new/choose
*/
), numbers as (
    select 0 as generated_number
    union 
    select *
    from (
        {{ dbt_utils.generate_series(upper_bound=1000) }} )
{% endif %}

), contact_merge_audit as (
    select
        contact.contact_id,
        {% if target.type == 'bigquery' %}
        split(merges, ':')[offset(0)]
        {% elif target.type == 'snowflake' %}
        split_part(merges.value, ':', 0)
        {% elif target.type == 'redshift' %}
        split_part(json_extract_array_element_text(json_serialize(split_to_array(calculated_merged_vids, ';')), cast(numbers.generated_number as {{ dbt.type_int() }}), true) ':', 1)
        {% elif target.type == 'postgres' %}
        split_part(merges, ':', 1)
        {% else %} 
        -- databricks/spark and postgres
        split_part(merges, ':', 1)
        {%- endif %} as vid_to_merge

    from contact
    cross join 
    {% if target.type == 'bigquery' %}
        unnest(cast(split(calculated_merged_vids, ";") as array<string>)) as merges

    {% elif targety.type == 'snowflake' %}
        table(flatten(STRTOK_TO_ARRAY(calculated_merged_vids, ';'))) as merges

    {% elif targety.type == 'redshift' %}
        numbers 
    where numbers.generated_number < json_array_length(json_serialize(split_to_array(calculated_merged_vids, ';')), true)
        or (numbers.generated_number + json_array_length(json_serialize(split_to_array(calculated_merged_vids, ';')), true) = 0)

    {% elif target.type == 'postgres' %}
        unnest(string_to_array(calculated_merged_vids, ';')) as merges
    
    {% else %} -- databricks/spark
        (select contact_id, explode(split(calculated_merged_vids, ';')) as merges) as merges_subquery 
        where contact.contact_id = merges_subquery.contact_id
    {% endif %}

{% endif %}
), contact_merge_removal as (
    select 
        contacts.*
    from contacts
    
    left join contact_merge_audit
        on contacts.contact_id = contact_merge_audit.vid_to_merge
    
    where contact_merge_audit.vid_to_merge is null
)

select *
from contact_merge_removal