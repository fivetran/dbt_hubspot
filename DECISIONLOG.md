## Deals with more than one owner ID
HubSpot treats a deal owner as a single value, but some connections sync a deal `owner_id` that holds several owner IDs separated by a semicolon (for example, `35252170;44023296`). Before v1.10.2, this value broke the owner join in `int_hubspot__deals_enhanced` on warehouses that implicitly cast it to a number, such as Snowflake.

When a deal has more than one owner ID, we match it to the **first** ID in the list. That owner's fields (for example, `owner_email_address` and `owner_full_name`) appear in `hubspot__deals`.

We chose the first ID because:
- HubSpot doesn't define a primary owner or an order for these values, so any choice is a convention. The first ID is the simplest one to explain.
- Returning one row per owner breaks the one-row-per-deal grain of `hubspot__deals` and `hubspot__deal_stages`, and double-counts deal amounts.

The `owner_id` column keeps the original value, so you can still see every owner ID on the deal. To report on the other owners, split `owner_id` in your own models.
