{% macro merge_contacts() -%}

{{ adapter.dispatch('merge_contacts', 'hubspot') () }}

{% endmacro %}

{% macro default__merge_contacts() %}
{# bigquery  #}
    select
        contacts.contact_id,
        split(merges, ':')[offset(0)] as vid_to_merge

    from contacts
    cross join 
        unnest(cast(split(calculated_merged_vids, ";") as array<string>)) as merges

{% endmacro %}

{% macro snowflake__merge_contacts() %}
    select
        contacts.contact_id,
        split_part(merges.value, ':', 0) as vid_to_merge
    
    from contacts
    cross join 
        table(flatten(STRTOK_TO_ARRAY(calculated_merged_vids, ';'))) as merges

{% endmacro %}

{% macro redshift__merge_contacts() %}
{#
Unfortunately, merged contact IDs are brought in as an array-like string, which different destinations handle completely differently. 
The below code serves to extract and pivot merged vids into individual rows. 
We are making the assumption that a user will not have more than 1000 merges into one contact. If that's wrong please open an issue!
https://github.com/fivetran/dbt_hubspot/issues/new/choose
#}
    select
        contacts.contact_id,
        split_part(json_extract_array_element_text(json_serialize(split_to_array(calculated_merged_vids, ';')), cast(numbers.generated_number as {{ dbt.type_int() }}), true), ':', 1) as vid_to_merge
    
    from contacts
    cross join (
        select 0 as generated_number
        union 
        select *
        from ({{ dbt_utils.generate_series(upper_bound=1000) }} )
    ) as numbers

    where numbers.generated_number < json_array_length(json_serialize(split_to_array(calculated_merged_vids, ';')), true)
        or (numbers.generated_number + json_array_length(json_serialize(split_to_array(calculated_merged_vids, ';')), true) = 0)

{% endmacro %}

{% macro postgres__merge_contacts() %}
    select
        contacts.contact_id,
        split_part(merges, ':', 1) as vid_to_merge

    from contacts
    cross join 
        unnest(string_to_array(calculated_merged_vids, ';')) as merges

{% endmacro %}

{% macro spark__merge_contacts() %}
{# databricks and spark #}
    select
        contacts.contact_id,
        split_part(merges, ':', 1) as vid_to_merge
    from contacts
    cross join (
        select 
            contact_id, 
            explode(split(calculated_merged_vids, ';')) as merges from contacts
    ) as merges_subquery 
    where contacts.contact_id = merges_subquery.contact_id

{% endmacro %}