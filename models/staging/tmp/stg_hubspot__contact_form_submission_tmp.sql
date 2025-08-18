{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_form_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','contact_form_submission')) }}
from {{ var('contact_form_submission') }}