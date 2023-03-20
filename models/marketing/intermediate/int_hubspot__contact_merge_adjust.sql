{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled'])) }}

with contacts as (

    select *
    from {{ var('contact') }}

{% if target.type == 'bigquery' or var('hubspot_contact_merge_audit_enabled', false) %}
), contact_merge_audit as (
    select *
    from {{ var('contact_merge_audit') }}
), contact_merge_removal as (
    select 
        contacts.*
    from contacts
    
    left join contact_merge_audit
        on contacts.contact_id = contact_merge_audit.vid_to_merge
    
    where contact_merge_audit.vid_to_merge is null
{% else %}

{% if target.type == 'redshift' %}
/*
Unfortunately, `email_list_ids` are brought in as a JSON ARRAY, which different destinations handle completely differently. 
The below code serves to extract and pivot list IDs into individual rows. 
Records with an empty `email_list_ids` array will just have one row. 
We are making the assumption that a user will not have more than 1000 lists. If that's wrong please open an issue!
https://github.com/fivetran/dbt_iterable/issues/new/choose
*/
), numbers as (
    select 0 as generated_number
    union 
    select *
    from (
        {{ dbt_utils.generate_series(upper_bound=1000) }} )
{% endif %}

), merged_contacts as (
    select
        contact_id,
        {% if target.type == 'bigquery' %}
        split(merges, ':')[offset(0)] as vid_to_merge
        {% elif target.type == 'snowflake' %}
        split_part(merges.value, ':', 0) as vid_to_merge
        {% elif target.type == 'redshift' %}
        split_part(json_extract_array_element_text(json_serialize(split_to_array(calculated_merged_vids, ';')), cast(numbers.generated_number as {{ dbt.type_int() }}), true) ':', 1)
        {% elif target.type == 'postgres' %}
        {# split_part(unnest(string_to_array(calculated_merged_vids, ';')), ':', 1)::bigint  as contact_id,
        split_part(unnest(string_to_array(calculated_merged_vids, ';')), ':', 1)::bigint  as vid_to_merge #}

    from contact
    cross join 
    {% if target.type == 'bigquery' %}
        unnest(cast(split(calculated_merged_vids, ";") as array<string>)) as merges
    {% elif targety.type == 'snowflake' %}
        table(flatten(STRTOK_TO_ARRAY(calculated_merged_vids, ';'))) as merges
    {% elif targety.type == 'redshift' %}
        numbers 
    where 
        numbers.generated_number < json_array_length(json_serialize(split_to_array(calculated_merged_vids, ';')), true)
        or (numbers.generated_number + json_array_length(json_serialize(split_to_array(calculated_merged_vids, ';')), true) = 0)
    {% elif target.type == 'postgres' %}

    {% else %} -- databricks
    
) 
{% endif %}
select *
from contact_merge_removal