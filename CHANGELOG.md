# dbt_hubspot v1.6.1

[PR #193](https://github.com/fivetran/dbt_hubspot/pull/193) includes the following updates:

## Test Fixes
- Removes duplicate column definitions in YAML schema files to avoid `dbt parse` warnings.
- Corrects descriptions for several fields. 

# dbt_hubspot v1.6.0

[PR #192](https://github.com/fivetran/dbt_hubspot/pull/192) includes the following updates:

## Documentation
- Updates README with standardized Fivetran formatting.

## Under the Hood
- In the `quickstart.yml` file:
  - Adds `supported_vars` for Quickstart UI customization.

# dbt_hubspot v1.5.0

## Schema/Data Changes
**3 total changes • 1 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ---------- | ----------- | -------- | -------- | ----- |
| `stg_hubspot__contact`<br>`hubspot__contacts` | Removed column | `calculated_merged_vids` | | Field deprecated in [v1.3.0](https://github.com/fivetran/dbt_hubspot/releases/tag/v1.3.0) has been sunset. Use `merged_object_ids` instead |
| `hubspot__email_sends` | Added column | | `was_unsubscribed` | Fix spelling error - replaces misspelled `was_unsubcribed` column |
| `hubspot__email_sends` | Deprecated column | `was_unsubcribed` | | [DEPRECATED] Maintained for backwards compatibility. Use `was_unsubscribed` instead. Will be removed in a future release. |

## Under the Hood
- Updates seeds and macros to support the schema changes.

# dbt_hubspot v1.4.0

[PR #188](https://github.com/fivetran/dbt_hubspot/pull/188) includes the following updates:

## Features
  - Increases the required dbt version upper limit to v3.0.0

# dbt_hubspot v1.3.0

[PR #186](https://github.com/fivetran/dbt_hubspot/pull/186) and [PR #187](https://github.com/fivetran/dbt_hubspot/pull/187) include the following updates:

## Schema/Data Change
**8 total changes • 6 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ------------- | ----------- | ----| --- | ----- |
| `stg_hubspot__owner_team`<br>`stg_hubspot__form`<br>`stg_hubspot__role`<br>`stg_hubspot__team`<br>`stg_hubspot__team_user`<br>`stg_hubspot__users` | New column | | `is_deleted` (aliased from `_fivetran_deleted`) | Boolean indicating whether a record has been deleted in Hubspot and/or inferred deleted in Hubspot by Fivetran |
| All models | New column | | `source_relation` | Identifies the source connection when using multiple hubspot connections |
| `hubspot__company_history` | Updated surrogate key | `id` = `company_id` + `field_name` + `valid_from` | `id` = `source_relation` + `company_id` + `field_name` + `valid_from` |  |
| `hubspot__contact_history` | Updated surrogate key | `id` = `contact_id` + `field_name` + `valid_from` | `id` = `source_relation` + `contact_id` + `field_name` + `valid_from` |  |
| `hubspot__deal_history` | Updated surrogate key | `id` = `deal_id` + `field_name` + `valid_from` | `id` = `source_relation` + `deal_id` + `field_name` + `valid_from` |  |
| `hubspot__daily_ticket_history` | Updated surrogate key | `ticket_day_id` = `date_day` + `ticket_id` | `ticket_day_id` = `source_relation` + `date_day` + `ticket_id` |  |
| `int_hubspot__pivot_daily_ticket_history`<br>`int_hubspot__ticket_calendar_spine` | Updated surrogate key | `id` = `date_day` + `ticket_id` | `id` = `source_relation` + `date_day` + `ticket_id` |  |
| `int_hubspot__daily_ticket_history` | Updated surrogate key | `id` = `date_day` + `ticket_id` + `field_name` | `id` = `source_relation` + `date_day` + `ticket_id` + `field_name` |  |

## Additional Breaking Changes
If you are currently using the `hubspot__company_pass_through_columns` or `hubspot__deal_pass_through_columns` variables to persist the `_fivetran_deleted` field, please add an `alias` to avoid duplicate column errors.

> Please note that `_fivetran_deleted` is coalesced with the `is_<company/deal>_eabled` field present in the `hubspot__companies`, `hubspot__deals`, and `hubspot__deal_stages` models.

```yml
vars:
  hubspot__company_pass_through_columns: 
    - name: "_fivetran_deleted" 
      alias: "_fivetran_company_deleted" # Can choose any alias other than _fivetran_deleted
  hubspot__deal_pass_through_columns: 
    - name: "_fivetran_deleted" 
      alias: "_fivetran_deal_deleted" # Can choose any alias other than _fivetran_deleted
```

## Feature Update
- **Union Data Functionality**: This release supports running the package on multiple hubspot source connections. See the [README](https://github.com/fivetran/dbt_hubspot/tree/main?tab=readme-ov-file#step-3-define-database-and-schema-variables) for details on how to leverage this feature.
- Coalesces `is_<company/deal>_deleted` with `_fivetran_deleted` in `stg_hubspot__company` and `stg_hubspot__deal`.

## Tests Update
- Removes uniqueness tests. The new unioning feature requires combination-of-column tests to consider the new `source_relation` column in addition to the existing primary key, but this is not supported across dbt versions.
- These tests will be reintroduced once a version-agnostic solution is available.
> We have kept uniqueness tests on the surrogate keys listed above.

## Under the Hood
- Ensures that the `datatype` config of `_fivetran_deleted`/`is_deleted` uses the cross-compatible `dbt.type_boolean()` macro.

## Contributors
- [@zhoward101](https://github.com/zhoward101) ([PR #186](https://github.com/fivetran/dbt_hubspot/pull/186))

# dbt_hubspot v1.2.0

[PR #182](https://github.com/fivetran/dbt_hubspot/pull/182) includes the following updates:

## Schema/Data Change
**5 total changes • 2 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ---------- | ----------- | -------- | -------- | ----- |
| [stg_hubspot__property](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.stg_hubspot__property) | Primary Key Change | `_fivetran_id` + `hubspot_object` | `property_name` + `hubspot_object` | The composite primary key is now `property_name` and `hubspot_object` instead of `_fivetran_id` and `hubspot_object`. The `_fivetran_id` field is marked as deprecated. |
| [stg_hubspot__property_option](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.stg_hubspot__property_option) | Primary Key Change | `property_id` + `property_option_label` | `property_option_name` + `hubspot_object` + `property_option_label` | The composite primary key is now `property_option_name`, `hubspot_object`, and `property_label` instead of `property_id` and `property_option_label`. The `property_id` field is marked as deprecated. |
| [stg_hubspot__property_option](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.stg_hubspot__property_option) | New Column | | `hubspot_object` | Added to support new composite primary key and joins with the `PROPERTY` table. |
| [stg_hubspot__property_option](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.stg_hubspot__property_option) | New Column | | `property_option_name` | Added to support new composite primary key. |
| [int_hubspot__email_aggregate_status_change](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.int_hubspot__email_aggregate_status_change) | New Column | | `unique_key` | Adds surrogate key generated from `email_campaign_id` and `email_send_id` to ensure uniqueness. Previously we only included `email_send_id` in its uniqueness test. |

## Bug Fix
- Fixes join condition in `hubspot__email_sends` model to include both `email_send_id` and `email_campaign_id` when joining with unsubscribes data, preventing potential data integrity issues with duplicate email send IDs across different campaigns.

## Under the Hood
- Updates join logic in the `add_property_labels` [macro](https://github.com/fivetran/dbt_hubspot/blob/main/macros/staging/add_property_labels.sql) to join `PROPERTY` and `PROPERTY_OPTION` on `hubspot_object` instead of `_fivetran_id/property_id`. This is used in the following staging models:
  - `stg_hubspot__company`
  - `stg_hubspot__contact`
  - `stg_hubspot__deal`
  - `stg_hubspot__ticket`
- Updates `get_property_option_columns` macro to include the new `hubspot_object` and `name` columns for property options.
- Updates uniqueness tests in `int_hubspot__email_aggregate_status_change` to use the new `unique_key` field instead of `email_send_id`.
- Updates documentation in staging models to reflect the deprecated status of `_fivetran_id` and `property_id` fields and explain the new composite primary key structure.
- Updates `property_option` seed data to include the newly added columns.
- Adds consistency data validation tests for `hubspot__companies`.

# dbt_hubspot v1.1.0

[PR #171](https://github.com/fivetran/dbt_hubspot/pull/171) includes the following updates:

## Schema/Data Changes
**3 total changes • 2 possible breaking changes**
| **Model** | **Change type** | **Old** | **New** | **Notes** |
|-----------|----------------|--------------|--------------|---------|
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts)<br>[int_hubspot__contact_merge_adjust](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.int_hubspot__contact_merge_adjust)<br>[stg_hubspot__contact](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.stg_hubspot__contact) | New Column | | `merged_object_ids` | This column is now used to merge contacts instead of `calculated_merged_vids`. It is more complete in that it captures multi-step or chained contact merges, which `calculated_merged_vids` does not. It is aliased from `property_hs_merged_object_ids` in the raw source data. |

**If you have the following configuration, please remove it.** Otherwise, the above field additions will produce duplicate column errors.
```yml
# dbt_project.yml
vars:
  hubspot__contact_pass_through_columns:
    - name: property_hs_merged_object_ids
      alias: merged_object_ids
```

## Under the Hood
- Adjusted join logic in `hubspot__tickets` to avoid potential data type mismatch errors.
- Updated `merge_contacts()` macro to reference `merged_object_ids` instead of `calculated_merged_vids`.
- Resolved a dbt Fusion error around `{% set abc = abc.append(...) %}`, as this syntax is valid only in dbt Core. We have opted for `do` instead of `set`.

## Documentation
- Updated README to clarify the default value of source-disabling/enabling variables [here](https://github.com/fivetran/dbt_hubspot?tab=readme-ov-file#step-4-disableenable-models-and-sources).

## Contributors
- [@b-per](https://github.com/b-per) ([#170](https://github.com/fivetran/dbt_hubspot/pull/170))

# dbt_hubspot v1.0.0

[PR #167](https://github.com/fivetran/dbt_hubspot/pull/167) includes the following updates:

## Breaking Changes

### Source Package Consolidation
- Removed the dependency on the `fivetran/hubspot_source` package.
  - All functionality from the source package has been merged into this transformation package for improved maintainability and clarity.
  - If you reference `fivetran/hubspot_source` in your `packages.yml`, you must remove this dependency to avoid conflicts.
  - Any source overrides referencing the `fivetran/hubspot_source` package will also need to be removed or updated to reference this package.
  - Update any hubspot_source-scoped variables to be scoped to only under this package. See the [README](https://github.com/fivetran/dbt_hubspot/blob/main/README.md#changing-the-build-schema) for how to configure the build schema of staging models.
- As part of the consolidation, vars are no longer used to reference staging models, and only sources are represented by vars. Staging models are now referenced directly with `ref()` in downstream models.

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.
  - Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_hubspot.yml`.

# dbt_hubspot v0.26.0
This release includes the following updates.

## Schema Changes 
**6 total changes • 6 possible breaking changes**
| **Data Model/Column** | **Change type** | **Old** | **New** | **Notes** |
|-----------|----------------|--------------|--------------|---------|
| [`hubspot__deal_stages`](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__deal_stages) | Column Renamed | `is_pipeline_stage_closed_won` | `is_pipeline_stage_closed` | Column renamed to more accurately match the source data. The column is generated via a coalesce between the previous `closed_won` source column and the newly added `is_closed` column. This renamed column represents whether a deal is closed, regardless of its label as “Closed Won” or “Closed Lost.” You can still use the `pipeline_stage_label` column to differentiate between "Closed Won" and "Closed Lost" stages. ([PR #161](https://github.com/fivetran/dbt_hubspot/pull/161)) |
| [`hubspot__tickets`](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__tickets)<br> - `ticket_pipeline_id` <br> - `ticket_pipeline_stage_id` | Column datatype |  `int` or `string` | `string`  | Explicitly cast ticket pipeline identifiers to string format to prevent datatype errors in compilation. (Upstream changes from [source PR #151](https://github.com/fivetran/dbt_hubspot_source/pull/151)) |
| [`stg_hubspot__deal_pipeline_stage`](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot_source.stg_hubspot__deal_pipeline_stage) | Column Renamed | `is_closed_won` | `is_closed` | Column renamed to more accurately match the source data. The renamed `is_closed` column is generated via a coalesce between the previous `closed_won` source column and the newly added `is_closed` column. This renamed column represents whether a deal is closed, regardless of its label as “Closed Won” or “Closed Lost.” You can still use the `pipeline_stage_label` column to differentiate between "Closed Won" and "Closed Lost" stages. ([PR #161](https://github.com/fivetran/dbt_hubspot/pull/161)) |
| [`stg_hubspot__ticket`](https://fivetran.github.io/dbt_hubspot_source/#!/model/model.hubspot_source.stg_hubspot__ticket)<br> - `ticket_pipeline_id` <br> - `ticket_pipeline_stage_id` | Column datatype | `int` or `string` | `string` | Explicitly cast ticket pipeline identifiers to string format to prevent datatype errors in compilation. ([Source PR #151](https://github.com/fivetran/dbt_hubspot_source/pull/151)) |
| [`stg_hubspot__ticket_pipeline`](https://fivetran.github.io/dbt_hubspot_source/#!/model/model.hubspot_source.stg_hubspot__ticket_pipeline)<br> - `ticket_pipeline_id`  | Column datatype | `int` | `string` | Changed cast of ticket pipeline identifier to the original string format to prevent datatype errors in compilation. ([Source PR #151](https://github.com/fivetran/dbt_hubspot_source/pull/151)) |
| [`stg_hubspot__ticket_pipeline_stage`](https://fivetran.github.io/dbt_hubspot_source/#!/model/model.hubspot_source.stg_hubspot__ticket_pipeline_stage)<br>- `ticket_pipeline_id` <br> - `ticket_pipeline_stage_id` <br> | Column datatype |  `int`  | `string`  | Changed cast of ticket pipeline identifiers to their original string format to prevent datatype errors in compilation. ([Source PR #151](https://github.com/fivetran/dbt_hubspot_source/pull/151)) |

## Bug Fixes
- Removed integer casting for `hs_pipeline` and `hs_pipeline_stage` in `hubspot__daily_ticket_history`, as `ticket_pipeline_id` and `ticket_pipeline_stage_id` are now strings from the schema changes above. ([PR #165](https://github.com/fivetran/dbt_hubspot/pull/165))

## Under the Hood
- Updated seed files to validate that the new identifiers compile as expected in both the source and transform packages. ([PR #165](https://github.com/fivetran/dbt_hubspot/pull/165))
- Documented the column updates and deprecations in the respective yml files. ([PR #161](https://github.com/fivetran/dbt_hubspot/pull/161))
- Updated the `deal_pipeline_stage_data` seed to include the `is_closed` column. ([PR #161](https://github.com/fivetran/dbt_hubspot/pull/161))
- Introduced the generate-docs github workflow for consistent docs generation. ([PR #161](https://github.com/fivetran/dbt_hubspot/pull/161))
- Added the `consistency_deal_stages` validation test to verify accuracy of the `hubspot__deal_stages` model on subsequent releases. ([PR #161](https://github.com/fivetran/dbt_hubspot/pull/161))
- Updated conditions in `.github/workflows/auto-release.yml`. ([PR #162](https://github.com/fivetran/dbt_hubspot/pull/162))
- Added `+docs: show: False` to `integration_tests/dbt_project.yml`. ([PR #162](https://github.com/fivetran/dbt_hubspot/pull/162))
- Migrated `flags` (e.g., `send_anonymous_usage_stats`, `use_colors`) from `sample.profiles.yml` to `integration_tests/dbt_project.yml`. ([PR #162](https://github.com/fivetran/dbt_hubspot/pull/162))
- Updated `maintainer_pull_request_template.md` with improved checklist. ([PR #162](https://github.com/fivetran/dbt_hubspot/pull/162))
- Updated `.gitignore` to exclude additional DBT, Python, and system artifacts. ([PR #162](https://github.com/fivetran/dbt_hubspot/pull/162))

# dbt_hubspot v0.25.0

[PR #160](https://github.com/fivetran/dbt_hubspot/pull/160) includes the following updates:

## Schema Changes
**8 total changes • 8 possible breaking changes**
| **Model** | **Change type** | **Old name** | **New name** | **Notes** |
|-----------|----------------|--------------|--------------|---------|
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts) | Column Renamed | `first_conversion_form_id` | `calculated_first_conversion_form_id` | Column renamed to avoid conflicts when passthrough columns are enabled. |
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts) | Column Renamed | `first_conversion_date` | `calculated_first_conversion_date` | Column renamed to avoid conflicts when passthrough columns are enabled. |
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts) | Column Renamed | `first_conversion_form_name` | `calculated_first_conversion_form_name` | Column renamed to avoid conflicts when passthrough columns are enabled. |
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts) | Column Renamed | `first_conversion_form_type` | `calculated_first_conversion_form_type` | Column renamed to avoid conflicts when passthrough columns are enabled. |
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts) | Column Renamed | `most_recent_conversion_form_id` | `calculated_most_recent_conversion_form_id` | Column renamed to avoid conflicts when passthrough columns are enabled. |
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts) | Column Renamed | `most_recent_conversion_date` | `calculated_most_recent_conversion_date` | Column renamed to avoid conflicts when passthrough columns are enabled. |
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts) | Column Renamed | `most_recent_conversion_form_name` | `calculated_most_recent_conversion_form_name` | Column renamed to avoid conflicts when passthrough columns are enabled. |
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts) | Column Renamed | `most_recent_conversion_form_type` | `calculated_most_recent_conversion_form_type` | Column renamed to avoid conflicts when passthrough columns are enabled. |

## Under the Hood
- Minor change to the `consistency_tickets` validation test to ensure it's only run when the service variable is enabled.
- Updated `contact_data` seed file to confirm duplicate column potential issue is addressed.

# dbt_hubspot v0.24.0

[PR #159](https://github.com/fivetran/dbt_hubspot/pull/159) includes the following updates:

## Breaking Change for dbt Core < 1.9.6

> *Note: This is not relevant to Fivetran Quickstart users.*

Migrated `freshness` from a top-level source property to a source `config` in alignment with [recent updates](https://github.com/dbt-labs/dbt-core/issues/11506) from dbt Core ([HubSpot Source v0.20.0](https://github.com/fivetran/dbt_hubspot_source/releases/tag/v0.20.0)). This will resolve the following deprecation warning that users running dbt >= 1.9.6 may have received:

```
[WARNING]: Deprecated functionality
Found `freshness` as a top-level property of `hubspot` in file
`models/src_hubspot.yml`. The `freshness` top-level property should be moved
into the `config` of `hubspot`.
```

**IMPORTANT:** Users running dbt Core < 1.9.6 will not be able to utilize freshness tests in this release or any subsequent releases, as older versions of dbt will not recognize freshness as a source `config` and therefore not run the tests.

If you are using dbt Core < 1.9.6 and want to continue running HubSpot freshness tests, please elect **one** of the following options:
  1. (Recommended) Upgrade to dbt Core >= 1.9.6
  2. Do not upgrade your installed version of the `hubspot` package. Pin your dependency on v0.23.0 in your `packages.yml` file.
  3. Utilize a dbt [override](https://docs.getdbt.com/reference/resource-properties/overrides) to overwrite the package's `hubspot` source and apply freshness via the previous release top-level property route. This will require you to copy and paste the entirety of the previous release `src_hubspot.yml` file and add an `overrides: hubspot_source` property.

## Under the Hood
- Updates to ensure integration tests use latest version of dbt.

# dbt_hubspot v0.23.0
[PR #157](https://github.com/fivetran/dbt_hubspot/pull/157) includes the following updates:

## Breaking Changes
- These updates are considered breaking due to changes in model schemas, including the addition of new columns and joins.

### New Models
- `int_hubspot__owners_enhanced`: Enriches owner records with team and role metadata
- `int_hubspot__form_metrics__by_contact`: Adds form submission and conversion metrics at the contact level
- `hubspot__engagement_communication`: Represents the relationship between communications and engagements

### Updated Models
The following models have been updated with new columns sourced from the new intermediate models. Refer to the linked documentation for more details.

- [`int_hubspot__owners_enhanced`](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.int_hubspot__owners_enhanced) is joined to:
  - [`hubspot__deals`](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__deals)
  - [`hubspot__tickets`](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__tickets)
  - New columns added to both models:
    - **Owner data**
      - `owner_active_user_id`
    - **Team data**:
      - `owner_primary_team_id`
      - `owner_primary_team_name`
      - `owner_all_team_ids`
      - `owner_all_team_names`
    - **Role data**:
      - `owner_role_id`
      - `owner_role_name`

- [`int_hubspot__form_metrics__by_contact`](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.int_hubspot__form_metrics__by_contact) is joined to:
  - [`hubspot__contacts`](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts)
  - New columns added:
    - `total_form_submissions`
    - `total_unique_form_submissions`
    - `first_conversion_form_id`
    - `first_conversion_date`
    - `first_conversion_form_name`
    - `first_conversion_form_type`
    - `most_recent_conversion_form_id`
    - `most_recent_conversion_date`
    - `most_recent_conversion_form_name`
    - `most_recent_conversion_form_type`

### Configuration Variables
The following variables control whether certain models or features are enabled based on your HubSpot connection.  
**Note:** This dynamic enablement only applies when using **Quickstart**. Models will automatically be disabled if their required source tables are missing.  
For **dbt Core users**, the default values below apply unless explicitly overridden.

- `hubspot_contact_form_enabled` (default: `true`)
- `hubspot_engagement_communication_enabled` (default: `false`)
- `hubspot_team_enabled` (default: `true`)
- `hubspot_role_enabled` (default: `true`)
- `hubspot_team_user_enabled` (default: `true`)

See [Step 4 of the README](https://github.com/fivetran/dbt_hubspot?tab=readme-ov-file#step-4-disable-models-for-non-existent-sources) for more details on the variables.

**Model behavior based on the above variables:**
- `int_hubspot__owners_enhanced`
  - Model enabled when `hubspot_owner_enabled` is `true` (existing variable)
  - Includes additional enrichment when the following are enabled:
    - `hubspot_team_enabled` – adds team-related columns
    - `hubspot_role_enabled` – adds role-related columns
  - Team and role enrichment are optional; you may enable either, both, or neither

- `hubspot__deals` and `hubspot__tickets`
  - Joins in `int_hubspot__owners_enhanced` when `hubspot_owner_enabled` is `true` (existing variable)
  - Inherit any team or role enrichment included in `int_hubspot__owners_enhanced`, based on its upstream configuration

- `int_hubspot__form_metrics__by_contact`
  - Enabled by `hubspot_contact_form_enabled`
- `hubspot__contacts`
  - Joins in `int_hubspot__form_metrics__by_contact` when `hubspot_contact_form_enabled` is `true`

- `hubspot__engagement_communication`
  - Enabled by `hubspot_engagement_communication_enabled`

## Documentation
- Added column-level descriptions for all new models and fields.

## Under the Hood
- Added seeds for each new source.

## Changes in dbt_hubspot_source
### New Sources and Staging Models
- Introduced new sources and their associated staging models to support expanded HubSpot data coverage:

| Source Table                | Staging Model                                 | Enablement Variable(s) - Default is true unless otherwise mentioned |
|-----------------------------|-----------------------------------------------|------------------------------------------|
| `contact_form_submission`   | `stg_hubspot__contact_form_submission`        | `hubspot_contact_form_enabled` <br> `hubspot_marketing_enabled` |
| `engagement_communication`  | `stg_hubspot__engagement_communication`       | `hubspot_engagement_communication_enabled` (default: false) <br> `hubspot_engagement_enabled` <br>  `hubspot_sales_enabled` |
| `form`                      | `stg_hubspot__form`                           | `hubspot_contact_form_enabled` <br>  `hubspot_marketing_enabled` |
| `owner_team`                | `stg_hubspot__owner_team`                     | `hubspot_team_enabled` |
| `role`                      | `stg_hubspot__role`                           | `hubspot_role_enabled` |
| `team`                      | `stg_hubspot__team`                           | `hubspot_team_enabled` |
| `team_user`                 | `stg_hubspot__team_user`                      | `hubspot_team_user_enabled` <br>  `hubspot_team_enabled` |
| `user`                      | `stg_hubspot__user`                           | `hubspot_role_enabled` |

- See [Step 4 of the README](https://github.com/fivetran/dbt_hubspot?tab=readme-ov-file#step-4-disable-models-for-non-existent-sources) for more details on enabling/disabling sources.
- Updated the `owner` source and `stg_hubspot__owner` staging model:
  - Added the `active_user_id` column.
  - Removed the requirement for `hubspot_sales_enabled` to be true since this logic now applies to multiple objects (e.g. tickets and deals) downstream.

## Under the Hood
- Added `get_*_columns` macros for each new source.

# dbt_hubspot v0.22.0

[PR #156](https://github.com/fivetran/dbt_hubspot/pull/156) includes the following updates:

## Deprecations
- Select fields have been deprecated from `hubspot__contact_lists` model as well as the upstream `stg_hubspot__contact_list` model (see HubSpot Source ([#137](https://github.com/fivetran/dbt_hubspot_source/pull/137)) for details). The full removal date is planned for May 10th, 2025. Follow [Deprecation Issue #138](https://github.com/fivetran/dbt_hubspot_source/issues/138) for more details and updates around the planned sunsetting of the fields.
  - The deprecated fields include the following:
    - `is_deletable`
    - `is_dynamic`
    - `metadata_error`
    - `metadata_last_processing_state_change_at`
    - `metadata_last_size_change_at`
    - `metadata_processing`
    - `metadata_size`
    - `portal_id`

## Breaking Changes
- Select fields have been added to the `hubspot__contact_lists` model as well as the upstream `stg_hubspot__contact_list` model (see HubSpot Source ([#137](https://github.com/fivetran/dbt_hubspot_source/pull/137)) for details).
  - The newly added fields include the following:
    - `created_by_id`
    - `object_type_id`
    - `processing_status`
    - `processing_type`
    - `list_version`
    - `filters_updated_at`

## Documentation
- All deprecated fields have been documented as notice of deprecation in the respective yml documents.
- All added fields have been documented. 

## Under the Hood
- Added a deprecation tracker GitHub issue template to ensure deprecated fields are appropriately tracked for full removal in a future planned update.
- Added consistency validation tests to ensure the `hubspot__contact_lists` model remains consistent on subsequent updates.
- Included an integrity validation test to ensure the accuracy of the `hubspot__contact_lists` model.
- Updated the daily ticket integrity and consistency tests to be turned off if the `hubspot_service_enabled` variable is disabled.

# dbt_hubspot v0.21.0
This release includes the following updates:

## Breaking Changes
- For Quickstart users, the models `hubspot__daily_ticket_history` and `hubspot__tickets` are now available within the Quickstart UI and are enabled by default. ([#154](https://github.com/fivetran/dbt_hubspot/pull/154))

## Documentation
- Added Quickstart model counts to README. ([#152](https://github.com/fivetran/dbt_hubspot/pull/152))
- Corrected references to connectors and connections in the README. ([#152](https://github.com/fivetran/dbt_hubspot/pull/152))

## Under the hood
- Added `hubspot__daily_ticket_history` and `hubspot__tickets` models to the `public_models` list in `quickstart.yml`. ([#154](https://github.com/fivetran/dbt_hubspot/pull/154))


# dbt_hubspot v0.21.0-a1
[PR #154](https://github.com/fivetran/dbt_hubspot/pull/154) includes the following updates:

## Documentation
- Added Quickstart model counts to README. ([#152](https://github.com/fivetran/dbt_hubspot/pull/152))
- Corrected references to connectors and connections in the README. ([#152](https://github.com/fivetran/dbt_hubspot/pull/152))

## Under the hood
- Added `hubspot__daily_ticket_history` and `hubspot__tickets` models to the `public_models` list in `quickstart.yml`.
  - This pre-release tests models that are disabled by default for compatibility with quickstart.

# dbt_hubspot v0.20.0
[PR #150](https://github.com/fivetran/dbt_hubspot/pull/150) includes the following updates:

## Upstream Breaking Changes (`--full-refresh` required after upgrading)
- Introduced a new `category` column to the following upstream models (see dbt_hubspot_source [CHANGELOG](https://github.com/fivetran/dbt_hubspot_source/blob/main/CHANGELOG.md#dbt_hubspot_source-v0170) notes). This association field differentiates records by either HUBSPOT_DEFINED (default label) or USER_DEFINED (custom label) and was introduced to the Hubspot connector in October 2024. See the [connector release notes](https://fivetran.com/docs/connectors/applications/hubspot/changelog#october2024) for more.
  - `stg_hubspot__deal_company`
  - `stg_hubspot__deal_contact`
  - `stg_hubspot__engagement_company`
  - `stg_hubspot__engagement_contact`
  - `stg_hubspot__engagement_deal`
  - `stg_hubspot__ticket_company`
  - `stg_hubspot__ticket_contact`
  - `stg_hubspot__ticket_deal`
  - `stg_hubspot__ticket_engagement`

- Since new columns were added upstream, a `--full-refresh` is needed.

## Under the Hood
- Updated the respective seed files in the integration_tests folder to property test for the new `category` field.
- Updated seed files to make consistent with the seed files in `dbt_hubspot_source`.

# dbt_hubspot v0.19.1
[PR #148](https://github.com/fivetran/dbt_hubspot/pull/148) includes the following updates:

## Under the Hood
- Removed `hubspot__daily_ticket_history`, `hubspot__tickets` from the quickstart.yml since these models may not always be present.

# dbt_hubspot v0.19.0
[PR #147](https://github.com/fivetran/dbt_hubspot/pull/147) includes the following updates:
## Breaking Changes 
> ⚠️ Since the following changes result in the table format changing, we recommend running a `--full-refresh` after upgrading to this version to avoid possible incremental failures.
- We have made this a breaking change due to upstream changes that may alter your schema. While changes are made 'behind the scenes' to now allow models to successfully run with both `hubspot__pass_through_all_columns` and `hubspot__<>_pass_through_columns`, this may be a breaking change due to leveraging the `remove_duplicate_and_prefix_from_columns` macro. This is a breaking change because this macro can remove duplicate fields, resulting in an impact to your schema. For more information refer to the [upstream dbt_hubspot_source v0.16.0 release notes](https://github.com/fivetran/dbt_hubspot_source/releases/tag/v0.16.0).

## Under the Hood
- Updated seed data to include fields with special syntax in order to test the above changes.

# dbt_hubspot v0.18.0
[PR #144](https://github.com/fivetran/dbt_hubspot/pull/144) includes the following updates:

## 🚨 Breaking Changes 🚨
> ⚠️ Since the following changes result in the table format changing, we recommend running a `--full-refresh` after upgrading to this version to avoid possible incremental failures.

- For Databricks All-Purpose clusters, incremental models will now be materialized using the delta table format (previously parquet).
  - Delta tables are generally more performant than parquet and are also more widely available for Databricks users. This will also prevent compilation issues on customers' managed tables.

- For Databricks SQL Warehouses, incremental materialization will not be used due to the incompatibility of the `insert_overwrite` strategy.

## Under the Hood
- The `is_incremental_compatible` macro has been added and will return `true` if the target warehouse supports our chosen incremental strategy.
  - This update was applied as there have been other Databricks runtimes discovered (ie. an endpoint and external runtime) which do not support the `insert_overwrite` incremental strategy used. 
- Added integration testing for Databricks SQL Warehouse.
- Added consistency tests for `hubspot__daily_ticket_history`.

# dbt_hubspot v0.17.2
[PR #142](https://github.com/fivetran/dbt_hubspot/pull/142) includes the following updates:

## 🪲 Bug Fixes 🪛
- Fixed the `fivetran_utils.enabled_vars` conditional by adding the `hubspot_contact_list_member_enabled` variable in the `hubspot__contact_lists` model. This solves for compilation errors when the `contact_list` source table is not synced in the destination. If `hubspot_contact_list_member_enabled` is `true`, `int_hubspot__email_metrics__by_contact_list` is brought in as a dependency, and ignored otherwise. 

## 🚘 Under the Hood 🚘
- Updated the `integration_tests/dbt_project.yml` variables to be global to ensure more effective testing of our seed data.
- Updated `property_closed_date` and `property_createdate` datatypes in `ticket_data` to cast as timestamp to fix datetime data type issues in BigQuery tests.
- Updated the maintainer PR template to resemble the most up to date format.
- Removed the check docs GitHub Action as it is no longer necessary.

# dbt_hubspot v0.17.1
[PR #140](https://github.com/fivetran/dbt_hubspot/pull/140) includes the following updates:

## Bug Fixes
- Included explicit datatype casts to `{{ dbt.type_string() }}` within the join of `contact_merge_audit.vid_to_merge` to `contacts.contact_id` in the `int_hubspot__contact_merge_adjust` model.
  - This update was required to address a bug where the IDs in the join would overflow to bigint or be interpreted as strings. This change ensures the join fields have matching datatypes.

# dbt_hubspot v0.17.0
[PR #137](https://github.com/fivetran/dbt_hubspot/pull/137) includes the following updates:

## 🚨 Breaking Changes: Variable Bug Fixes 🚨 
- The following are now dependent on the `hubspot_email_event_sent_enabled` variable being defined as `true`:
  -`hubspot__contact_lists` email metric fields
  -`hubspot__contact` email metric fields
  -`hubspot__email_campaigns` model
  -`int_hubspot__email_metrics__by_contact_list` model
> **Note**: This is a breaking change for users who have the `hubspot_email_event_sent_enabled` variable set to `false` as this update will change the above behaviors of the package. For all other users, these changes will not be breaking. 

# dbt_hubspot v0.16.0
[PR #135](https://github.com/fivetran/dbt_hubspot/pull/135) includes the following updates:

## 🚨 Breaking Changes 🚨
- Added unique tests on `event_id` for event-based models, `contact_id` for `hubspot__contacts`, `contact_list_id` for `hubspot__contact_lists`, `deal_id` for `hubspot__deals`, `deal_stage_id` for `hubspot__deal_stages`, and `company_id` for `hubspot__companies`, on the condition the titular fields have not been deleted. We would advise running through these to ensure they work successfully.

## Features
- Updates the `hubspot__deal_stages` and `hubspot__deals` models to remove stale deals that have been merged since into other deals. In addition we've introduced a new field `merged_deal_ids` that lists all historic merged deals for each deal. 
   - **Please note** you must have the underlying `merged_deals` table to take advantage of the above mentioned merged deal update. This may be enabled by setting `hubspot_merged_deal_enabled` to True (by default this will be False). Also, `hubspot_sales_enabled` and `hubspot_deal_enabled` must not be set to False (by default these are True). See [Step 4 of the README](https://github.com/fivetran/dbt_hubspot#step-4-disable-models-for-non-existent-sources) for more details. 

## Variable Bug Fixes
- The following adjustments have been made concerning the `hubspot_contact_enabled` variable:
  - The `email_events_joined()` macro now includes conditional logic to include contact information only if the `hubspot_contact_enabled` variable is defined as `true`.
  - The `int_hubspot__email_metrics__by_contact_list` model is now dependent on the `hubspot_contact_enabled` variable being defined as `true`.
  - The `hubspot__contact_lists` model now takes into consideration the `hubspot_contact_enabled` variable being defined as `true` before joining in email metric information to the contact lists data.
- Modified the config enabled logic within the `hubspot__email_sends` model to be dependent on the `hubspot_email_event_sent_enabled` variable being `true` in addition to the `hubspot_marketing_enabled` and `hubspot_email_event_enabled` variables.

## Under the Hood
- Added quickstart.yml for Quickstart customers.
- Added `not_null` tests that were previously missing to `deal_id` for `hubspot__deals` and `deal_stage_id` for `hubspot__deal_stages`.

# dbt_hubspot v0.15.1
[PR #129](https://github.com/fivetran/dbt_hubspot/pull/129) includes the following updates:

## Bug Fixes
- Updated model `int_hubspot__deals_enhanced` so that fields from the `owner` source are not included when `hubspot_owner_enabled` is set to false. 

## Under the Hood
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_hubspot v0.15.0

[PR #127](https://github.com/fivetran/dbt_hubspot/pull/127) includes the following updates:

## Bug fixes
- Updated variables used to determine if engagements are enabled in `hubspot__contacts` to also check variable `hubspot_engagement_contact_enabled`.

## Features
- The following changes stem from changes made in the source package. See the [source package v0.14.0 CHANGELOG entry](https://github.com/fivetran/dbt_hubspot_source/blob/main/CHANGELOG.md#dbt_hubspot_source-v0140) for more details. 

- Added the following staging models, along with documentation and tests:
  - `stg_hubspot__property`
  - `stg_hubspot__property_option`
  - These tables can be disabled by setting `hubspot_property_enabled: False` in your dbt_project.yml vars. See [Step 4 of the README](https://github.com/fivetran/dbt_hubspot#step-4-disable-models-for-non-existent-sources) for more details. 

- When including a passthrough `property_hs_*` column, you now have the option to include the corresponding, human-readable labels. 
  - The above-mentioned `property` tables are required for this feature. If you do not have them and have to disable them, unfortunately you will not be able to use this feature.
  - See the [Adding property label section](https://github.com/fivetran/dbt_hubspot#adding-property-label) of the README for more details on how to enable this feature! 
  - We recommend being selective with the label columns you add. As you add more label columns, your run time will increase due to the underlying logic requirements.
  - This update applies to models:
    - `hubspot__companies`
    - `hubspot__contacts`
    - `hubspot__deals`
    - `hubspot__tickets` 

# dbt_hubspot v0.14.0

## 🚨 Breaking Changes 🚨
- Within the source package the `created_at` and `closed_at` fields in the below mentioned staging models have been renamed to `created_date` and `closed_date` respectively to be consistent with the source data. Additionally, this will ensure there are no duplicate column errors when passing through all `property_*` columns, which could potentially conflict with `property_created_at` or `property_closed_at`. ([PR #119](https://github.com/fivetran/dbt_hubspot_source/pull/119))
  - `stg_hubspot__company`
    - Impacts `hubspot__companies`
  - `stg_hubspot__contact`
    - Impacts `hubspot__contacts`
  - `stg_hubspot__deal`
    - Impacts `hubspot__deals`
  - `stg_hubspot__ticket`
    - Impacts `hubspot__tickets`

## New Model Alert 😮
Introducing Service end models! These are disabled by default but can be enabled by setting `hubspot_service_enabled` to `true` ([PR #123](https://github.com/fivetran/dbt_hubspot/pull/123)):
  - `hubspot__tickets` - [Docs](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__tickets)
  - `hubspot__daily_ticket_history` - [Docs](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__daily_ticket_history)
    - See additional configurations for the history model in [README](https://github.com/fivetran/dbt_hubspot/tree/main#daily-ticket-history)

## Features
- Addition of the following variables to allow the disabling of the `*_property_history` models if they are not being leveraged. All variables are `true` by default. ([PR #122](https://github.com/fivetran/dbt_hubspot/pull/122))
  - `hubspot_company_property_history_enabled`
  - `hubspot_contact_property_history_enabled`
  - `hubspot_deal_property_history_enabled`

## Under the Hood
- Updates to the seed files and seed file configurations for the package integration tests to ensure updates are properly tested. ([PR #122](https://github.com/fivetran/dbt_hubspot/pull/122))

# dbt_hubspot v0.13.0
## 🚨 Breaking Changes 🚨
- This release will be a breaking change due to the removal of below dependencies.
## Dependency Updates
- Removes the dependencies on [dbt-expectations](https://github.com/calogica/dbt-expectations/releases) and [dbt-date](https://github.com/calogica/dbt-date/releases). ([PR #118](https://github.com/fivetran/dbt_hubspot/pull/118))

## Under the Hood
- Specifically we removed the `dbt_expectations.expect_column_values_to_be_unique` test that was used to validate uniqueness under given conditions for the primary keys among the end models. We will be working to replace this with a similar test. ([PR #118](https://github.com/fivetran/dbt_hubspot/pull/118))

# dbt_hubspot v0.12.0

## 🚨 Breaking Changes 🚨
- This release includes breaking changes as a result of upstream changes within the `v0.12.0` release of the dbt_hubspot_source package. Please see below for the relevant breaking change release notes from the source package. ([PR #120](https://github.com/fivetran/dbt_hubspot/pull/120))
- The following models in the dbt_hubspot_source package now use a custom macro to remove the property_hs_ prefix in staging columns, while also preventing duplicates. If de-prefixed columns match existing ones (e.g., `property_hs_meeting_outcome` vs. `meeting_outcome`), the macro favors the `property_hs_`field, aligning with the latest HubSpot API update. ([PR #115](https://github.com/fivetran/dbt_hubspot_source/pull/115))
  - `stg_hubspot__engagement_call`
  - `stg_hubspot__engagement_company`
  - `stg_hubspot__engagement_contact`
  - `stg_hubspot__engagement_deal`
  - `stg_hubspot__engagement_email`
  - `stg_hubspot__engagement_meeting`
  - `stg_hubspot__engagement_note`
  - `stg_hubspot__engagement_task`
  - `stg_hubspot__ticket`
  - `stg_hubspot__ticket_company`
  - `stg_hubspot__ticket_contact`
  - `stg_hubspot__ticket_deal`
  - `stg_hubspot__ticket_engagement`
  - `stg_hubspot__ticket_property_history`

# dbt_hubspot v0.11.0
[PR #114](https://github.com/fivetran/dbt_hubspot/pull/114) includes the following updates:
## 🚨 Breaking Changes 🚨
This change is made breaking in part to updates applied to the upstream [dbt_hubspot_source](https://github.com/fivetran/dbt_hubspot_source/pull/112) package following upgrades to ensure compatibility with the HubSpot v3 API updates. Please see below for the relevant upstream changes:

- Following the [May 2023 connector update](https://fivetran.com/docs/applications/hubspot/changelog#may2023) the HubSpot connector now syncs the below parent and child tables from the new v3 API. As a result the dependent fields and field names from the downstream staging models have changed depending on the fields available in your HubSpot data. Now the respective staging models will sync the required fields for the dbt_hubspot downstream transformations and **all** of your `property_hs_*` fields. Please be aware that the `property_hs_*` will be truncated from the field name in the staging and downstream models. The impacted sources (and relevant staging models) are below:
```txt
  - `ENGAGEMENT`
    - `ENGAGEMENT_CALL`
    - `ENGAGEMENT_COMPANY`
    - `ENGAGEMENT_CONTACT`
    - `ENGAGEMENT_DEAL`
    - `ENGAGEMENT_EMAIL`
    - `ENGAGEMENT_MEETING`
    - `ENGAGEMENT_NOTE`
    - `ENGAGEMENT_TASK`
  - `TICKET`
    - `TICKET_COMPANY`
    - `TICKET_CONTACT`
    - `TICKET_DEAL`
    - `TICKET_ENGAGEMENT`
    - `TICKET_PROPERTY_HISTORY`
```
  - Please note that while these changes are breaking, the package has been updated to ensure backwards compatibility with the pre HubSpot v3 API updates. As a result, you may see some `null` fields which are artifacts of the pre v3 API HubSpot version. Be sure to inspect the relevant field descriptions for an understanding of which fields remain for backwards compatibility purposes. These fields will be removed once all HubSpot connectors are upgraded to the v3 API.

- The `engagements_joined` macro has been adjusted to account for the HubSpot v3 API changes. In particular, the fields that used to only be available in the `engagements` source are now available in the individual `engagement_[type]` sources. As such, coalesce statements were added to ensure the correct populated fields are used following the join. Further, to avoid ambiguous columns a `dbt-utils.star` was added to remove the explicitly declared columns within the coalesce statements.
  - The coalesce is only included for backwards compatibility. This will be removed in a future release when all HubSpot connectors are on the latest API version.

## Under the Hood
- The `base_model` argument used for the `engagements_joined` macro has been updated to be an explicit `ref` as opposed to the previously used `var` within the below models:
  - `hubspot__engagement_calls`
  - `hubspot__engagement_emails`
  - `hubspot__engagement_meetings`
  - `hubspot__engagement_notes`
  - `hubspot__engagement_tasks`
    - This update was applied as the `var` result was producing inconsistent results during compile and runtime when leveraging the `dbt-utils.star` macro. However, the explicit `ref` always provided consistent results. 

## Documentation Updates
- As new fields were added in the v3 API updates, and old fields were removed, the documentation was updated to reflect the v3 API consistent fields. Please take note if you are still using the pre v3 API, you will find the following end models no longer have complete field documentation coverage:
  - `hubspot__engagement_calls`
  - `hubspot__engagement_emails`
  - `hubspot__engagement_meetings`
  - `hubspot__engagement_notes`
  - `hubspot__engagement_tasks`
# dbt_hubspot v0.10.1

## 🪲 Bug Fixes
Explicitly casts join fields (`engagement_id` and `deal_id`) in `hubspot__deals` as the appropriate data types to avoid potential errors in joining. [PR #113](https://github.com/fivetran/dbt_hubspot/pull/113)

# dbt_hubspot v0.10.0
## 🚨 Breaking Changes 🚨
These changes are made breaking due to changes in the source. 
- Columns `updated_at` and `created_at` were added to the following sources and their corresponding staging models in the [source package](https://github.com/fivetran/dbt_hubspot_source):
  - `DEAL_PIPELINE`
  - `DEAL_PIPELINE_STAGE`
  - `TICKET_PIPELINE`
  - `TICKET_PIPELINE_STAGE`
- As a result, the following columns have been added ([#111](https://github.com/fivetran/dbt_hubspot/pull/111)): 
  - Model `hubspot__deals`:
    - `deal_pipeline_created_at`
    - `deal_pipeline_updated_at`
  - Model `hubspot__deal_stages`:
    - `deal_pipeline_stage_created_at`
    - `deal_pipeline_stage_updated_at`
- Documentation has also been updated with these new columns. ([#111](https://github.com/fivetran/dbt_hubspot/pull/111))

## 🎉 Feature Updates
- Updated README to include the variables `hubspot_ticket_deal_enabled` and `hubspot_owner_enabled`. ([#111](https://github.com/fivetran/dbt_hubspot/pull/111))

## 🚘 Under the Hood
- Modified the `unnest` logic in the `merge_contacts` macro for **Redshift** users to reduce runtime of the `int_hubspot__contact_merge_adjust` model. ([#110](https://github.com/fivetran/dbt_hubspot/pull/110))
- Updated seed data for testing newly added columns. ([#111](https://github.com/fivetran/dbt_hubspot/pull/111))

## Contributors
- @kcraig-ats ([#110](https://github.com/fivetran/dbt_hubspot/pull/110))

See upstream `hubspot_source` release notes [here](https://github.com/fivetran/dbt_hubspot_source/blob/main/CHANGELOG.md).

# dbt_hubspot v0.9.1

## 🎉 Feature Updates
- A new variable was added `hubspot_using_all_email_events` to allow package users to remove filtered email events from the `stg_hubspot__email_event` staging model as well as the relevant downstream reporting models. This is crucial for HubSpot users who greatly take advantage of marking events as filtered in order to provide accurate reporting. ([#104](https://github.com/fivetran/dbt_hubspot/pull/104))
  - The `hubspot_using_all_email_events` variable is `true` by default. Set the variable to `false` to filter out specified email events in your staging and downstream models. ([#104](https://github.com/fivetran/dbt_hubspot/pull/104))

## 🪲 Bug Fixes
- Introduced new macro `adjust_email_metrics` to prevent failures that may occur when certain tables are disabled or enabled. This macro removes any metrics that are unavailable from the default `email_metrics` list, ensuring that the models runs smoothly. It's worth noting that you can still manually set the email_metrics list as described in the README's [(Optional) Step 5: Additional configurations](https://github.com/fivetran/dbt_hubspot/#optional-step-5-additional-configurations). ([#105](https://github.com/fivetran/dbt_hubspot/pull/105))

## 🚘 Under the Hood
- The `email_event_data.csv` seed file was updated to include events that are listed as `true` for filtered_events. This is to effectively test the above mentioned feature update. ([#104](https://github.com/fivetran/dbt_hubspot/pull/104))
- Included `hubspot_using_all_email_events: false` as a variable declared in the final `run_models.sh` step to ensure our integration tests gain coverage over this new feature and variable. ([#104](https://github.com/fivetran/dbt_hubspot/pull/104))
  - See the source package [CHANGELOG](https://github.com/fivetran/dbt_hubspot_source/blob/main/CHANGELOG.md) for updates made to the staging layer in `dbt_hubspot_source v0.9.1`.
- Updated the following models to utilize the `adjust_email_metrics` macro ([#105](https://github.com/fivetran/dbt_hubspot/pull/105)):
  - hubspot__contacts
  - hubspot__contact_lists
  - hubspot__email_campaigns
  - int_hubspot__email_metrics__by_contact_list
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([#103](https://github.com/fivetran/dbt_hubspot/pull/103))
- Updated the pull request [templates](/.github). ([#103](https://github.com/fivetran/dbt_hubspot/pull/103))

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
