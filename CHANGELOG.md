# dbt_hubspot v0.9.1
## 🪲 Bug Fixes
[PR #105](https://github.com/fivetran/dbt_hubspot/pull/105) applies the following changes:
- Introduced new macro `get_email_metrics` to prevent failures that may occur when certain tables are disabled or enabled. This macro removes any metrics that are unavailable from the default `email_metrics` list, ensuring that the macro runs smoothly. It's worth noting that you can still manually set the email_metrics list as described in the README's [(Optional) Step 5: Additional configurations](https://github.com/fivetran/dbt_hubspot/#optional-step-5-additional-configurations).
## 🚘 Under the Hood
- Updated the following models to utilize the new macro:
  - hubspot__contacts
  - hubspot__contact_lists
  - hubspot__email_campaigns

# dbt_hubspot v0.9.0

## 🚨 Breaking Changes 🚨
In [November 2022](https://fivetran.com/docs/applications/hubspot/changelog#november2022), the Fivetran Hubspot connector switched to v3 of the Hubspot CRM API, which deprecated the `CONTACT_MERGE_AUDIT` table and stored merged contacts in a field in the `CONTACT` table. **This has not been rolled out to BigQuery warehouses yet.** BigQuery connectors with the `CONTACT_MERGE_AUDIT` table enabled will continue to sync this table until the new `CONTACT.property_hs_calculated_merged_vids` field and API version becomes available to them.

This release introduces breaking changes around how contacts are merged in order to align with the above connector changes. It is, however, backwards-compatible.

[PR #100](https://github.com/fivetran/dbt_hubspot/pull/100) applies the following changes:
- Updates logic around the recently deprecated `CONTACT_MERGE_AUDIT` table.
  - The package now leverages the new `property_hs_calculated_merged_vids` field to filter out merged contacts. This is the default behavior for all destinations, _including BigQuery_ (the package will run successfully but not actually merge any contacts). This is achieved by the package's new `merge_contacts()` macro.
  - **Backwards-compatibility:** the package will only reference the old `CONTACT_MERGE_AUDIT` table to merge contacts if `hubspot_contact_merge_audit_enabled` is explicitly set to `true` in your root `dbt_project.yml` file.
  - The `int_hubspot__contact_merge_adjust` model (where the package performs contact merging) is now materialized as a table by default. This used to be ephemeral, but the reworked merge logic requires this model to be either a table or view.

## Under the Hood
[PR #100](https://github.com/fivetran/dbt_hubspot/pull/100) applies the following changes:
- Updates seed data to test new merging paradigm.

See the source package [CHANGELOG](https://github.com/fivetran/dbt_hubspot_source/blob/main/CHANGELOG.md) for updates made to the staging layer in `dbt_hubspot_source v0.9.0`.

# dbt_hubspot v0.8.2
## Bug Fixes
- Following the release of `v0.8.0`, the end model uniqueness tests were not updated to account for the added flexibility of the inclusion of deleted records. As such the respective end model tests have been adjusted to test uniqueness only on non-deleted records. ([#94](https://github.com/fivetran/dbt_hubspot/pull/94))

## Under the Hood
- Addition of the dbt-expectations package to be used for more robust testing of uniqueness for end models. ([#94](https://github.com/fivetran/dbt_hubspot/pull/94))

# dbt_hubspot v0.8.0

## 🚨 Breaking Changes 🚨:
[PR #92](https://github.com/fivetran/dbt_hubspot/pull/92) incorporates the following changes:

- The below models/macros have new soft deleted record flags **explicitly** added to them:
  - `is_contact_deleted` added in `macros/email_events_joined` which can affect the following downstream models found in `models/marketing/email_events/`:
    - `hubspot__email_event_bounce`
    - `hubspot__email_event_clicks`
    - `hubspot__email_event_deferred`
    - `hubspot__email_event_delivered`
    - `hubspot__email_event_dropped`
    - `hubspot__email_event_forward`
    - `hubspot__email_event_open`
    - `hubspot__email_event_print`
    - `hubspot__email_event_sent`
    - `hubspot__email_event_spam_report`
    - `hubspot__email_event_status_change`
  - `is_deal_pipeline_deleted` and `is_deal_pipeline_stage_deleted` added in `models/sales/intermediate/int_hubspot__deals_enhanced` which can affect the following downstream models found in `models/sales/`:
    - `hubspot__deal_stages`
    - `hubspot__deals`
  - `is_deal_pipeline_deleted`, `is_deal_pipeline_stage_deleted` and `is_deal_deleted` added in `models/sales/hubspot__deal_stages`

- Soft deleted records are also now **implicitly** inherited (e.g. via a `select *`) from the `dbt_hubspot_source` package's staging models and can affect the below final models (for more information, see [dbt_hubspot_source PR #96](https://github.com/fivetran/dbt_hubspot_source/pull/96)):
  - Soft deleted company records (`companies.is_company_deleted`) included in the below models:
    - `sales/hubspot__companies`
  - Soft deleted deal records (`deals.is_deal_deleted`) included in the below models:
    - `sales/hubspot__deal_stages`
    - `sales/hubspot__deals`
  - Soft deleted contact list records (`contact_lists.is_contact_list_deleted`) included in the below models:
    - `marketing/hubspot__contact_lists`
  - Soft deleted contact records (`contacts.is_contact_deleted`) included in the below models:
    - `marketing/hubspot__contacts`
  - Soft deleted email sends records (`sends.is_contact_deleted`) included in the below models:
    - `marketing/hubspot__email_sends`

- For completeness, soft deleted records are also now included for `ticket*` tables, however does not currently affect this package directly and includes the following staging models:
    - `stg_hubspot__ticket` (`is_ticket_deleted`)
    - `stg_hubspot__ticket_pipeline_stage`(`is_ticket_pipeline_stage_deleted`)
    - `stg_hubspot__ticket_pipeline` (`is_ticket_pipeline_deleted`)

# dbt_hubspot v0.7.0

## 🚨 Breaking Changes 🚨:
[PR #86](https://github.com/fivetran/dbt_hubspot/pull/86) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- `dbt_utils.surrogate_key` has also been updated to `dbt_utils.generate_surrogate_key`. Since the method for creating surrogate keys differ, we suggest all users do a `full-refresh` for the most accurate data. For more information, please refer to dbt-utils [release notes](https://github.com/dbt-labs/dbt-utils/releases) for this update.
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

## 🎉 Features
- 🧱 Databricks compatibility! [(PR #89)](https://github.com/fivetran/dbt_hubspot/pull/89)

# dbt_hubspot v0.6.3
PR [#84](https://github.com/fivetran/dbt_hubspot/pull/84) incorporates the following updates:
## Fixes
- Added column descriptions that were missing in [our documentation](https://fivetran.github.io/dbt_hubspot/#!/overview).

# dbt_hubspot v0.6.2
## Under the Hood
- Updated the docs as there were issues with the previous deployment. ([#82](https://github.com/fivetran/dbt_hubspot/pull/82))
- Introduced a GitHub workflow to ensure docs are re-built prior to merges to `main`. ([#82](https://github.com/fivetran/dbt_hubspot/pull/82))
# dbt_hubspot v0.6.1
## Fixes
- The README had holdover merge artifacts included within it. Those artifacts have since been removed in this release. [#80](https://github.com/fivetran/dbt_hubspot/pull/80)

## Contributors
- [@cristianwebber](https://github.com/cristianwebber) ([#80](https://github.com/fivetran/dbt_hubspot/pull/80))

# dbt_hubspot v0.6.0
## 🎉 Documentation and Feature Updates
- Updated README documentation updates for easier navigation and setup of the dbt package ([#67](https://github.com/fivetran/dbt_hubspot/pull/67)).
- Included `hubspot_[source_table_name]_identifier` variable for additional flexibility within the package when source tables are named differently ([#67](https://github.com/fivetran/dbt_hubspot/pull/67)).
- Adds `hubspot_ticket_deal_enabled` variable (default value=`False`) to disable modelling and testing of the `ticket_deal` source table. If there are no associations between tickets and deals in your Hubspot environment, this table will not exist ([#79](https://github.com/fivetran/dbt_hubspot_source/pull/79)).

## 🚨 Breaking Changes 🚨
- The `hubspot__deal_stages` model has undergone two major changes ([#78](https://github.com/fivetran/dbt_hubspot/pull/78)):
  1. The stage and pipeline label columns now reflect where the deal was at a certain point of time (from `date_stage_entered` to `date_stage_exited`). Previously, this information reflected the deal's _current_ stage and pipeline in every record associated with the deal.
  2. This model previously passed through _all_ fields from the parent deals model. We removed these fields, as they are all present in `hubspot__deals` final model and do not change across deal stages. If you would like to join `DEAL` fields into the `hubspot__deal_stages` model, join `hubspot__deal_stages` with `hubspot__deals` on `deal_id`.
- Consistently renames `property_dealname`, `property_closedate`, and `property_createdate` to `deal_name`, `closed_at`, and `created_at`, respectively, in the `deals` model. Previously, if `hubspot__pass_through_all_columns = true`, only the prefix `property_` was removed from the names of these fields, while they were completely renamed to `deal_name`, `closed_at`, and `created_at` if `hubspot__pass_through_all_columns = false` ([#79](https://github.com/fivetran/dbt_hubspot_source/pull/79)).

# dbt_hubspot v0.5.4
## Fixes
- Typo fix and spelling correction within the README. ([#70](https://github.com/fivetran/dbt_hubspot/pull/70))
- Spelling correction of the variable names within the README. ([#74](https://github.com/fivetran/dbt_hubspot/pull/74))

## Contributors
- [@moreaupascal56](https://github.com/moreaupascal56) ([#70](https://github.com/fivetran/dbt_hubspot/pull/70), [#74](https://github.com/fivetran/dbt_hubspot/pull/74))

# dbt_hubspot v0.5.3
## Under the Hood
- Added integration testing to support the new `stg_hubspot__deal_contact` model to the `dbt_hubspot_source` package.
- Updated the below models such that the respective `lead()` functions also account for `field_name` in partitions
  - `hubspot__contact_history`
  - `hubspot__company_history`
  - `hubspot__deal_history`
- Added test cases for the above models that can be found, respectively, in: 
  - `models/marketing/history/history.yml`
  - `models/sales/history/history.yml`
# dbt_hubspot v0.5.2
## Under the Hood
- Updated the `engagements_joined` [macro](https://github.com/fivetran/dbt_hubspot/blob/main/macros/engagements_joined.sql) to conditionally include relevant fields if their respective variables are enabled. Previously if a variable was disabled then the `hubspot__engagement_calls` model, which depends on the `engagements_joined` macro, would error out on the missing fields that were from the disabled variables. ([#65](https://github.com/fivetran/dbt_hubspot/pull/65))

# dbt_hubspot v0.5.1
## Under the Hood
- Modified the join conditions within the `deal_fields_joined` cte of int_hubspot__deals_enhanced model to leverage the more appropriate `left join` rather than the `using` condition. This is to allow for correct and accurate joins across warehouses. ([#60](https://github.com/fivetran/dbt_hubspot/pull/60))

# dbt_hubspot v0.5.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_hubspot_source`. Additionally, the latest `dbt_hubspot_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_hubspot v0.1.0 -> v0.4.1
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
