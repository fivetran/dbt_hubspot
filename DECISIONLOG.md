## Decision Log

### Joining email events to contacts that share an email address
More than one contact can hold the same email address, for example a deleted contact and a live contact. To keep one row per event, each email event joins to one contact:

1. A live contact before a deleted contact.
2. Then the most recently created contact.

A live contact wins even if it was created after the event. A contact is often deleted and recreated, and the contact table has no deletion date. So the current state wins, and email metrics follow the live contact. For details, see [issue #235](https://github.com/fivetran/dbt_hubspot/issues/235).
