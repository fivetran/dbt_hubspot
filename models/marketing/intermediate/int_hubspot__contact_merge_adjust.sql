{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_enabled', 'hubspot_contact_merge_audit_enabled'])) }}

with contacts as (

    select *
    from {{ var('contact') }}

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
)

select *
from contact_merge_removal