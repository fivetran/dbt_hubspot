with sends as (

    select *
    from {{ var('email_event_sent') }}

)

select *
from sends