{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled'])) }}

with contacts as (

    select *
    from {{ var('contact') }}
), contact_merge_audit as (
{% if var('hubspot_contact_merge_audit_enabled', false) %}
    select *
    from {{ var('contact_merge_audit') }}

{% else %}
    {{ merge_contacts() }}

{% endif %}
), contact_merge_removal as (
    select 
        contacts.*
    from contacts
    
    left join contact_merge_audit
        on contacts.contact_id = cast(contact_merge_audit.vid_to_merge as {{ dbt.type_int() }})
    
    where contact_merge_audit.vid_to_merge is null
)

select *
from contact_merge_removal