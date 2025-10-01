{% macro merge_contacts() -%}

{{ adapter.dispatch('merge_contacts', 'hubspot') () }}

{% endmacro %}

{% macro default__merge_contacts() %}
{# bigquery  #}
    select
        contacts.contact_id,
        merges as vid_to_merge

    from contacts
    cross join 
        unnest(cast(split(merged_object_ids, ";") as array<string>)) as merges

{% endmacro %}

{% macro snowflake__merge_contacts() %}
    select
        contacts.contact_id,
        merges.value as vid_to_merge
    
    from contacts
    cross join 
        table(flatten(STRTOK_TO_ARRAY(merged_object_ids, ';'))) as merges

{% endmacro %}

{% macro redshift__merge_contacts() %}
	select
        unnest_vid_array.contact_id,
        cast(vid_to_merge as {{ dbt.type_string() }}) as vid_to_merge
    from (
        select 
            contacts.contact_id,
            split_to_array(merged_object_ids, ';') as super_merged_object_ids
        from contacts
    ) as unnest_vid_array, unnest_vid_array.super_merged_object_ids as vid_to_merge

{% endmacro %}

{% macro postgres__merge_contacts() %}
    select
        contacts.contact_id,
        merges as vid_to_merge

    from contacts
    cross join 
        unnest(string_to_array(merged_object_ids, ';')) as merges

{% endmacro %}

{% macro spark__merge_contacts() %}
{# databricks and spark #}
    select
        contacts.contact_id,
        merges as vid_to_merge
    from contacts
    cross join (
        select 
            contact_id, 
            explode(split(merged_object_ids, ';')) as merges from contacts
    ) as merges_subquery 
    where contacts.contact_id = merges_subquery.contact_id

{% endmacro %}
