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
