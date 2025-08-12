{{ config(enabled=fivetran_utils.enabled_vars(['hubspot_marketing_enabled', 'hubspot_contact_form_enabled'])) }}

select {{ dbt_utils.star(source('hubspot','form')) }}
from {{ var('form') }}