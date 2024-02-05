<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_hubspot/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a> 
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

# HubSpot Transformation dbt Package ([Docs](https://fivetran.github.io/dbt_hubspot/))
# 📣 What does this dbt package do?
- Produces modeled tables that leverage HubSpot data from [Fivetran's connector](https://fivetran.com/docs/applications/hubspot) in the format described by [this ERD](https://fivetran.com/docs/applications/hubspot#schemainformation) and build off the output of our [HubSpot source package](https://github.com/fivetran/dbt_hubspot_source).
- Enables you to better understand your HubSpot email and engagement performance. The package achieves this by performing the following:
    - Generates models for contacts, companies, and deals with enriched email and engagement metrics.
    - Provides analysis-ready event tables for email and engagement activities.
- Generates a comprehensive data dictionary of your source and modeled HubSpot data through the [dbt docs site](https://fivetran.github.io/dbt_hubspot/).

<!--section="hubspot_transformation_model"-->
The following table provides a detailed list of all models materialized within this package by default.
> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_hubspot/#!/overview?g_v=1).

| **model**                | **description**                                                                                                      |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| [hubspot__companies](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__companies)         | Each record represents a company in Hubspot, enriched with metrics about engagement activities.                      |
| [hubspot__company_history](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__company_history) | Each record represents a change to a company in Hubspot, with `valid_to` and `valid_from` information.               |
| [hubspot__contacts](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contacts)        | Each record represents a contact in Hubspot, enriched with metrics about email and engagement activities.            |
| [hubspot__contact_history](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contact_history) | Each record represents a change to a contact in Hubspot, with `valid_to` and `valid_from` information.               |
| [hubspot__contact_lists](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__contact_lists)   | Each record represents a contact list in Hubspot, enriched with metrics about email activities.                      |
| [hubspot__deals](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__deals)            | Each record represents a deal in Hubspot, enriched with metrics about engagement activities.                         |
| [hubspot__deal_stages](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__deal_stages)            | Each record represents when a deal stage changes in Hubspot, enriched with metrics about deal activities.                         |
| [hubspot__deal_history](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__deal_history)    | Each record represents a change to a deal in Hubspot, with `valid_to` and `valid_from` information.                  |
| [hubspot__tickets](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__tickets)    | Each record represents a ticket in Hubspot, enriched with metrics about engagement activities and information on associated deals, contacts, companies, and owners.                  |
| [hubspot__daily_ticket_history](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__daily_ticket_history)    | Each record represents a ticket's day in Hubspot with tracked properties pivoted out into columns.               |
| [hubspot__email_campaigns](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__email_campaigns) | Each record represents a email campaign in Hubspot, enriched with metrics about email activities.                    |
| [hubspot__email_event_*](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__email_event_bounce)   | Each record represents an email event in Hubspot, joined with relevant tables to make them analysis-ready.           |
| [hubspot__email_sends](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__email_sends)     | Each record represents a sent email in Hubspot, enriched with metrics about opens, clicks, and other email activity. |
| [hubspot__engagement_*](https://fivetran.github.io/dbt_hubspot/#!/model/model.hubspot.hubspot__engagement_calls)    | Each record represents an engagement event in Hubspot, joined with relevant tables to make them analysis-ready.      |
<!--section-end-->

# 🎯 How do I use the dbt package?

## Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran HubSpot connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Database Incremental Strategies 
Some of the models (`+hubspot__daily_ticket_history`) in this package are materialized incrementally. We have chosen `insert_overwrite` as the default strategy for **BigQuery** and **Databricks** databases, as it is only available for these dbt adapters. For **Snowflake**, **Redshift**, and **Postgres** databases, we have chosen `delete+insert` as the default strategy.

`insert_overwrite` is our preferred incremental strategy because it will be able to properly handle updates to records that exist outside the immediate incremental window. That is, because it leverages partitions, `insert_overwrite` will appropriately update existing rows that have been changed upstream instead of inserting duplicates of them--all without requiring a full table scan.

`delete+insert` is our second-choice as it resembles `insert_overwrite` but lacks partitions. This strategy works most of the time and appropriately handles incremental loads that do not contain changes to past records. However, if a past record has been updated and is outside of the incremental window, `delete+insert` will insert a duplicate record. 😱
> Because of this, we highly recommend that **Snowflake**, **Redshift**, and **Postgres** users periodically run a `--full-refresh` to ensure a high level of data quality and remove any possible duplicates.

## Step 2: Install the package
Include the following hubspot package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/hubspot
    version: [">=0.16.0", "<0.17.0"] # we recommend using ranges to capture non-breaking changes automatically

```
Do **NOT** include the `hubspot_source` package in this file. The transformation package itself has a dependency on it and will install the source package as well.

### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

## Step 3: Define database and schema variables
### Option 1: Single connector 💃
By default, this package runs using your destination and the `hubspot` schema. If this is not where your hubspot data is (for example, if your hubspot schema is named `hubspot_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    hubspot_database: your_destination_name
    hubspot_schema: your_schema_name
```
> **Note**: If you are running the package on one source connector, each model will have a `source_relation` column that is just an empty string.

### Option 2: Union multiple connectors 👯
If you have multiple Hubspot connectors in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `hubspot_union_schemas` OR `hubspot_union_databases` variables (cannot do both, though a more flexible approach is in the works...) in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
    hubspot_union_schemas: ['hubspot_usa','hubspot_canada'] # use this if the data is in different schemas/datasets of the same database/project
    hubspot_union_databases: ['hubspot_usa','hubspot_canada'] # use this if the data is in different databases/projects but uses the same schema name
```

#### Recommended: Incorporate unioned sources into DAG
By default, this package defines one single-connector source, called `hubspot`, which will be disabled if you are unioning multiple connectors. This means that your DAG will not include your Hubspot sources, though the package will run successfully.

To properly incorporate all of your Hubspot connectors into your project's DAG:
1. Define each of your sources in a `.yml` file in your project. Utilize the following template to leverage our table and column documentation.

  <details><summary><i>Expand for source configuration template</i></summary><p>

> **Note**: If there are source tables you do not have (see [Step 4](https://github.com/fivetran/dbt_hubspot_source?tab=readme-ov-file#step-4-disable-models-for-non-existent-sources)), you may still include them here, as long as you have set the right variables to `False`. Otherwise, you may remove them from your source definition.

```yml
sources:
  - name: <name>
    schema: <schema_name>
    database: <database_name>
    loader: Fivetran
    loaded_at_field: _fivetran_synced
    tables: &hubspot_table_defs # <- see https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors/
      - name: calendar_event
        description: Each record represents a calendar event.
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: avatar_url
            description: URL of image associated with social media event.
          - name: campaign_guid
            description: Value of campaign GUID associated with Task.
          - name: category
            description: |
              Type of event. If the event type is PUBLISHING_TASK, it is one of BLOG_POST, EMAIL, LANDING_PAGE, CUSTOM.
              If event type is SOCIAL, it is one of twitter, facebook, linkedin, googlepluspages.
              If event type is CONTENT, it is one of email, recurring-email, blog-post, landing-page, legacy-page, site-page.
          - name: category_id
            description: |
              For event type of PUBLISHING_TASK, a numeric value corresponding to the type of task; one of 3 (BLOG_POST), 2 (EMAIL), 1 (LANDING_PAGE), 0 (CUSTOM).
              For event type of SOCIAL, this is 0.
              If event type is CONTENT, it is one of 2 (email, recurring-email), 3 (blog-post), 1 (landing-page), 5 (legacy-page), 4 (site-page).
          - name: content_group_id
            description: |
              The ID of the content group (aka blog) that the associated Blog Post belongs to, if any.
              Otherwise null. Only populated for single task GETs and for Blog Post Tasks.
          - name: content_id
            description: ID value of the COS content object associated with the event, null for social or if nothing associated.
          - name: created_by
            description: HubSpot ID of the user that the event was created by.
          - name: description
            description: Description of Event.
          - name: event_date
            description: If task, When the task is set to be due, otherwise when the event is/ was scheduled for; in milliseconds since the epoch.
          - name: event_type
            description: Type of calendar event; for tasks this is PUBLISHING_TASK, for COS Items, this is CONTENT, for social media events, this is SOCIAL
          - name: id
            description: The unique ID of the task.
          - name: is_recurring
            description: Whether the event is recurring.
          - name: name
            description: Name of Event.
          - name: owner_id
            description: TASK - HubSpot ID of the user that the task is assigned to.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: preview_key
            description: Preview key of content object; used for showing previews of unpublished items.
          - name: social_display_name
            description: Social media full name associate with event.
          - name: social_username
            description: Social media user name associated with event.
          - name: state
            description: For type publishing task, value of TODO or DONE, for others, a value of SCHEDULED, PUBLISHED, PUBLISHED_OR_SCHEDULED.
          - name: topic_ids
            description: The list of IDs of topics associated with the associated Blog Post, if any. Otherwise null. Only populated for single task GETs and for Blog Post Tasks.
          - name: url
            description: Public URL of content item.

      - name: company
        description: Each record represents a company in Hubspot.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_company_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: id
            description: The ID of the company.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: is_deleted
            description: '{{ doc("is_deleted") }}'
          - name: property_name
            description: The name of the company.
          - name: property_description
            description: A short statement about the company's mission and goals.
          - name: property_createdate
            description: The date the company was added to your account.
          - name: property_industry
            description: The type of business the company performs.
          - name: property_address
            description: The street address of the company.
          - name: property_address_2
            description: Additional address information for the company.
          - name: property_city
            description: The city where the company is located.
          - name: property_state
            description: The state where the company is located.
          - name: property_country
            description: The country where the company is located.
          - name: property_annualrevenue
            description: The actual or estimated annual revenue of the company.

      - name: company_property_history
        description: Each record represents a change to company record in Hubspot.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_company_enabled', true) and var('hubspot_company_property_history_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: company_id
            description: The ID of the related company record.
          - name: name
            description: '{{ doc("history_name") }}'
          - name: source
            description: '{{ doc("history_source") }}'
          - name: source_id
            description: '{{ doc("history_source_id") }}'
          - name: timestamp
            description: '{{ doc("history_timestamp") }}'
          - name: value
            description: '{{ doc("history_value") }}'

      - name: contact_merge_audit
        description: >
          DEPRECATED FOR NON-BIGQUERY USERS (will be deprecated on BigQuery as well). Each record contains a contact merge event and the contacts effected by the merge.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_contact_merge_audit_enabled', false) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: canonical_vid
            description: The contact ID of the contact which the vid_to_merge contact was merged into.
          - name: contact_id
            description: The ID of the contact.
          - name: entity_id
            description: The ID of the related entity.
          - name: first_name
            description: The contact's first name.
          - name: last_name
            description: The contact's last name.
          - name: num_properties_moved
            description: The number of properties which were removed from the merged contact.
          - name: timestamp
            description: Timestamp of when the contacts were merged.
          - name: user_id
            description: The ID of the user.
          - name: vid_to_merge
            description: The ID of the contact which was merged.

      - name: contact
        freshness:
          warn_after: {count: 84, period: hour}
          error_after: {count: 168, period: hour}
        description: Each record represents a contact in Hubspot.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_contact_enabled', true) }}"
        columns:
          - name: _fivetran_deleted
            description: '{{ doc("_fivetran_deleted") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: id
            description: The ID of the contact.
          - name: property_email_1
            description: The email address of the contact.
          - name: property_company
            description: The name of the contact's company.
          - name: property_firstname
            description: The contact's first name.
          - name: property_lastname
            description: The contact's last name.
          - name: property_email
            description: The contact's email.
          - name: property_createdate
            description: The date that the contact was created in your HubSpot account.
          - name: property_jobtitle
            description: The contact's job title.
          - name: property_annualrevenue
            description: The contact's annual company revenue.
          - name: property_hs_calculated_merged_vids
            description: >
              List of mappings representing contact IDs that have been merged into the contact at hand.
              Format: <merged_contact_id>:<merged_at_in_epoch_time>;<second_merged_contact_id>:<merged_at_in_epoch_time>
              This field has replaced the `CONTACT_MERGE_AUDIT` table, which was deprecated by the Hubspot v3 CRM API.

      - name: contact_form_submission
        description: Table containing contact form submission information
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: contact_id
            description: The ID of the related contact.
          - name: conversion_id
            description: A Unique ID for the specific form conversion.
          - name: form_id
            description: The GUID of the form that the submission belongs to.
          - name: page_url
            description: The URL that the form was submitted on, if applicable.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: timestamp
            description: A Unix timestamp in milliseconds of the time the submission occurred.
          - name: title
            description: The title of the page that the form was submitted on. This will default to the name of the form if no title is provided.

      - name: contact_list
        description: Each record represents a contact list in Hubspot.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_contact_list_enabled', true) }}"
        columns:
          - name: _fivetran_deleted
            description: '{{ doc("_fivetran_deleted") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: created_at
            description: A timestamp of the time the list was created.
          - name: deleteable
            description: If this is false, this is a system list and cannot be deleted.
          - name: dynamic
            description: Whether the contact list is dynamic.
          - name: id
            description: The ID of the contact list.
          - name: metadata_error
            description: Any errors that happened the last time the list was processed.
          - name: metadata_last_processing_state_change_at
            description: A timestamp of the last time that the processing state changed.
          - name: metadata_last_size_change_at
            description: A timestamp of the last time that the size of the list changed.
          - name: metadata_processing
            description: |
              One of DONE, REFRESHING, INITIALIZING, or PROCESSING.
              DONE indicates the list has finished processing, any other value indicates that list membership is being evaluated.
          - name: metadata_size
            description: The approximate number of contacts in the list.
          - name: name
            description: The name of the contact list.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: updated_at
            description: A timestamp of the time that the list was last modified.

      - name: contact_list_member
        description: Each record represents a 'link' between a contact and a contact list.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_contact_list_member_enabled', true) }}"
        columns:
          - name: _fivetran_deleted
            description: '{{ doc("_fivetran_deleted") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: added_at
            description: The timestamp a contact was added to a list.
          - name: contact_id
            description: The ID of the related contact.
          - name: contact_list_id
            description: The ID of the related contact list.

      - name: contact_property_history
        freshness:
          warn_after: {count: 84, period: hour}
          error_after: {count: 168, period: hour}
        description: Each record represents a change to contact record in Hubspot.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_contact_property_enabled', true) and var('hubspot_contact_property_history_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: contact_id
            description: The ID of the related contact record.
          - name: name
            description: '{{ doc("history_name") }}'
          - name: source
            description: '{{ doc("history_source") }}'
          - name: source_id
            description: '{{ doc("history_source_id") }}'
          - name: timestamp
            description: '{{ doc("history_timestamp") }}'
          - name: value
            description: '{{ doc("history_value") }}'

      - name: deal
        description: Each record represents a deal in Hubspot.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) }}"
        columns:
          - name: deal_id
            description: The ID of the deal.
          - name: is_deleted
            description: Whether the record was deleted.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: deal_pipeline_id
            description: The ID of the deal's pipeline.
          - name: deal_pipeline_stage_id
            description: The ID of the deal's pipeline stage.
          - name: owner_id
            description: The ID of the deal's owner. 
          - name: property_dealname
            description: The name you have given this deal.
          - name: property_description
            description: A brief description of the deal.
          - name: property_amount
            description: The total value of the deal in the deal's currency.
          - name: property_closedate
            description: The day the deal is expected to close, or was closed.
          - name: property_createdate
            description: The date the deal was created. This property is set automatically by HubSpot.

      - name: deal_stage
        description: Each record represents a deal stage.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) }}"
        columns:
          - name: _fivetran_active
            description: Boolean indicating whether the deal stage is active.
          - name: _fivetran_end
            description: The Fivetran calculated exist time of the deal stage. 
          - name: _fivetran_start
            description: The date the deal stage was entered.
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: date_entered
            description: The timestamp the deal stage was entered.
          - name: deal_id
            description: Reference to the deal.
          - name: source
            description: The relevant source of the deal stage.
          - name: source_id
            description: Reference to the source.
          - name: value
            description: The value of the deal stage. Typically the name of the stage.

      - name: deal_company
        description: Each record represents a 'link' between a deal and company.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) and var('hubspot_deal_company_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: company_id
            description: The ID of the company.
          - name: deal_id
            description: The ID of the deal.
          - name: type_id
            description: The ID of the type.

      - name: deal_contact
        description: Each record represents a 'link' between a deal and a contact.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) and var('hubspot_deal_contact_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: contact_id
            description: The ID of the contact.
          - name: deal_id
            description: The ID of the deal.
          - name: type_id
            description: The ID of the type.

      - name: deal_pipeline
        description: Each record represents a pipeline in Hubspot.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) }}"
        columns:
          - name: _fivetran_deleted
            description: '{{ doc("_fivetran_deleted") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: active
            description: Whether the stage is currently in use.
          - name: display_order
            description: Used to determine the order in which the pipelines appear when viewed in HubSpot.
          - name: label
            description: The human-readable label for the pipeline. The label is used when showing the pipeline in HubSpot.
          - name: pipeline_id
            description: The ID of the pipeline.
          - name: created_at
            description: A timestamp representing when the record was created.
          - name: updated_at
            description: A timestamp representing when the record was updated.

      - name: deal_pipeline_stage
        description: Each record represents a pipeline stage in Hubspot.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) }}"
        columns:
          - name: _fivetran_deleted
            description: '{{ doc("_fivetran_deleted") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: active
            description: Whether the pipeline stage is currently in use.
          - name: closed_won
            description: Whether the stage represents a Closed Won deal.
          - name: display_order
            description: Used to determine the order in which the stages appear when viewed in HubSpot.
          - name: label
            description: The human-readable label for the stage. The label is used when showing the stage in HubSpot.
          - name: pipeline_id
            description: The ID of the related pipeline.
          - name: probability
            description: The probability that the deal will close. Used for the deal forecast.
          - name: stage_id
            description: The ID of the pipeline stage.
          - name: created_at
            description: A timestamp representing when the record was created.
          - name: updated_at
            description: A timestamp representing when the record was updated.

      - name: deal_property_history
        description: Each record represents a change to deal record in Hubspot.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_deal_enabled', true) and var('hubspot_deal_property_history_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: deal_id
            description: The ID of the related deal record.
          - name: name
            description: '{{ doc("history_name") }}'
          - name: source
            description: '{{ doc("history_source") }}'
          - name: source_id
            description: '{{ doc("history_source_id") }}'
          - name: timestamp
            description: '{{ doc("history_timestamp") }}'
          - name: value
            description: '{{ doc("history_value") }}'

      - name: email_campaign
        description: Each record represents an email campaign in Hubspot.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: app_id
            description: The app ID.
          - name: app_name
            description: The app name.
          - name: content_id
            description: The ID of the content.
          - name: id
            description: The ID of the email campaign.
          - name: name
            description: The name of the email campaign.
          - name: num_included
            description: The number of messages included as part of the email campaign.
          - name: num_queued
            description: The number of messages queued as part of the email campaign.
          - name: sub_type
            description: The email campaign sub-type.
          - name: subject
            description: The subject of the email campaign.
          - name: type
            description: The email campaign type.

      - name: email_event
        freshness:
          warn_after: {count: 84, period: hour}
          error_after: {count: 168, period: hour}
        description: Each record represents an email event in Hubspot.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: app_id
            description: The ID of the app that sent the email.
          - name: caused_by_created
            description: The timestamp of the event that caused this event.
          - name: caused_by_id
            description: The event ID which uniquely identifies the event which directly caused this event. If not applicable, this property is omitted.
          - name: created
            description: The created timestamp of the event.
          - name: email_campaign_id
            description: The ID of the related email campaign.
          - name: filtered_event
            description: A boolean representing whether the event has been filtered out of reporting based on customer reports settings or not.
          - name: id
            description: The ID of the event.
          - name: obsoleted_by_created
            description: The timestamp of the event that made the current event obsolete.
          - name: obsoleted_by_id
            description: The event ID which uniquely identifies the follow-on event which makes this current event obsolete. If not applicable, this property is omitted.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: recipient
            description: The email address of the contact related to the event.
          - name: sent_by_created
            description: The timestamp of the SENT event related to this event.
          - name: sent_by_id
            description: The event ID which uniquely identifies the email message's SENT event. If not applicable, this property is omitted.
          - name: type
            description: The type of event.

      - name: email_event_bounce
        description: Each record represents a BOUNCE email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_bounce_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: category
            description: |
              The best-guess of the type of bounce encountered.
              If an appropriate category couldn't be determined, this property is omitted. See below for the possible values.
              Note that this is a derived value, and may be modified at any time to improve the accuracy of classification.
          - name: id
            description: The ID of the event.
          - name: response
            description: The full response from the recipient's email server.
          - name: status
            description: The status code returned from the recipient's email server.

      - name: email_event_click
        description: Each record represents a CLICK email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_click_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: browser
            description: '{{ doc("email_event_browser") }}'
          - name: id
            description: The ID of the event.
          - name: ip_address
            description: '{{ doc("email_event_ip_address") }}'
          - name: location
            description: '{{ doc("email_event_location") }}'
          - name: referer
            description: The URL of the webpage that linked to the URL clicked. Whether this is provided, and what its value is, is determined by the recipient's email client.
          - name: url
            description: The URL within the message that the recipient clicked.
          - name: user_agent
            description: '{{ doc("email_event_user_agent") }}'

      - name: email_event_deferred
        description: Each record represents a DEFERRED email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_deferred_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: attempt
            description: The delivery attempt number.
          - name: id
            description: The ID of the event.
          - name: response
            description: The full response from the recipient's email server.

      - name: email_event_delivered
        description: Each record represents a DELIVERED email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_delivered_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: id
            description: The ID of the event.
          - name: response
            description: The full response from the recipient's email server.
          - name: smtp_id
            description: An ID attached to the message by HubSpot.

      - name: email_event_dropped
        description: Each record represents a DROPPED email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_dropped_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: bcc
            description: The 'bcc' field of the email message.
          - name: cc
            description: The 'cc' field of the email message.
          - name: drop_message
            description: The raw message describing why the email message was dropped. This will usually provide additional details beyond 'dropReason'.
          - name: drop_reason
            description: The reason why the email message was dropped. See below for the possible values.
          - name: from
            description: The 'from' field of the email message.
          - name: id
            description: The ID of the event.
          - name: reply_to
            description: The 'reply-to' field of the email message.
          - name: subject
            description: The subject line of the email message.

      - name: email_event_forward
        description: Each record represents a FORWARD email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_forward_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: browser
            description: '{{ doc("email_event_browser") }}'
          - name: id
            description: The ID of the event.
          - name: ip_address
            description: '{{ doc("email_event_ip_address") }}'
          - name: location
            description: '{{ doc("email_event_location") }}'
          - name: user_agent
            description: '{{ doc("email_event_user_agent") }}'

      - name: email_event_open
        description: Each record represents a OPEN email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_open_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: browser
            description: '{{ doc("email_event_browser") }}'
          - name: duration
            description: If provided and nonzero, the approximate number of milliseconds the user had opened the email.
          - name: id
            description: The ID of the event.
          - name: ip_address
            description: '{{ doc("email_event_ip_address") }}'
          - name: location
            description: '{{ doc("email_event_location") }}'
          - name: user_agent
            description: '{{ doc("email_event_user_agent") }}'

      - name: email_event_print
        description: Each record represents a PRINT email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_print_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: browser
            description: '{{ doc("email_event_browser") }}'
          - name: id
            description: The ID of the event.
          - name: ip_address
            description: '{{ doc("email_event_ip_address") }}'
          - name: location
            description: '{{ doc("email_event_location") }}'
          - name: user_agent
            description: '{{ doc("email_event_user_agent") }}'

      - name: email_event_sent
        description: Each record represents a SENT email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_sent_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: bcc
            description: The 'cc' field of the email message.
          - name: cc
            description: The 'bcc' field of the email message.
          - name: from
            description: The 'from' field of the email message.
          - name: id
            description: The ID of the event.
          - name: reply_to
            description: The 'reply-to' field of the email message.
          - name: subject
            description: The subject line of the email message.

      - name: email_event_spam_report
        description: Each record represents a SPAM_REPORT email event.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_spam_report_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: id
            description: The ID of the event.
          - name: ip_address
            description: '{{ doc("email_event_ip_address") }}'
          - name: user_agent
            description: '{{ doc("email_event_user_agent") }}'

      - name: email_event_status_change
        description: Each record represents a STATUS_CHANGE email event in Hubspot.
        config:
          enabled: "{{ var('hubspot_marketing_enabled', true) and var('hubspot_email_event_enabled', true) and var('hubspot_email_event_status_change_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: bounced
            description: |
              A HubSpot employee explicitly initiated the status change to block messages to the recipient.
              (Note this usage has been deprecated in favor of dropping messages with a 'dropReason' of BLOCKED_ADDRESS.)
          - name: id
            description: The ID of the event.
          - name: portal_subscription_status
            description: |
              The recipient's portal subscription status.
              Note that if this is 'UNSUBSCRIBED', the property 'subscriptions' is not necessarily an empty array, nor are all
              subscriptions contained in it necessarily going to have their statuses set to 'UNSUBSCRIBED'.)
          - name: requested_by
            description: The email address of the person requesting the change on behalf of the recipient. If not applicable, this property is omitted.
          - name: source
            description: The source of the subscription change.
          - name: subscriptions
            description: |
              An array of JSON objects representing the status of subscriptions for the recipient.
              Each JSON subscription object is comprised of the properties: 'id', 'status'.

      - name: email_subscription
        description: Each record represents an email subscription in Hubspot.
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: active
            description: Whether the subscription is active.
          - name: description
            description: The description of the subscription.
          - name: id
            description: The ID of the email subscription.
          - name: name
            description: The name of the email subscription.
          - name: portal_id
            description: '{{ doc("portal_id") }}'

      - name: email_subscription_change
        description: Each record represents a change to an email subscription in Hubspot.
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: caused_by_event_id
            description: The ID of the event that caused the subscription change.
          - name: change
            description: The change which occurred. This enumeration is specific to the 'changeType'; see below for the possible values.
          - name: change_type
            description: The type of change which occurred.
          - name: email_subscription_id
            description: The ID of the related email subscription.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: recipient
            description: The email address of the related contact.
          - name: source
            description: The source of the subscription change.
          - name: timestamp
            description: The timestamp when this change occurred. If 'causedByEvent' is present, this will be absent.

      - name: engagement
        description: Each record represents an engagement
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: active
            description: >
              Whether the engagement is currently being shown in the UI.

              PLEASE NOTE: This field will not be populated for connectors utilizing the HubSpot v3 API version. This field will be deprecated in a future release.
          - name: created_at
            description: >
              A timestamp representing when the engagement was created.

              PLEASE NOTE: This field will not be populated for connectors utilizing the HubSpot v3 API version. This field will be deprecated in a future release.
          - name: id
            description: The ID of the engagement.
          - name: owner_id
            description: >
              The ID of the engagement's owner.

              PLEASE NOTE: This field will not be populated for connectors utilizing the HubSpot v3 API version. This field will be deprecated in a future release.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: timestamp
            description: >
              A timestamp in representing the time that the engagement should appear in the timeline.

              PLEASE NOTE: This field will not be populated for connectors utilizing the HubSpot v3 API version. This field will be deprecated in a future release.
          - name: type
            description: One of NOTE, EMAIL, TASK, MEETING, or CALL, the type of the engagement.

      - name: engagement_call
        description: Each record represents a CALL engagement event.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_call_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: engagement_id
            description: The ID of the engagement.
          - name: _fivetran_deleted
            description: Boolean to mark rows that were deleted in the source database.
          - name: property_hs_createdate
            description: >
              This field marks the call's time of creation and determines where the call sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: timestamp
            description: > 
              This field marks the call's time of occurrence and determines where the call sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_owner_id
            description: > 
              The ID of the owner associated with the call. This field determines the user listed as the call creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_team_id
            description: >
              The ID of the team associated with the call. This field determines the team listed as the call creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version.

      - name: engagement_company
        description: Each record represents a 'link' between a company and an engagement.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_company_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: company_id
            description: The ID of the related company.
          - name: engagement_id
            description: The ID of the related engagement.

      - name: engagement_contact
        description: Each record represents a 'link' between a contact and an engagement.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_contact_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: contact_id
            description: The ID of the related contact.
          - name: engagement_id
            description: The ID of the related engagement.

      - name: engagement_deal
        description: Each record represents a 'link' between a deal and an engagement.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_deal_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: deal_id
            description: The ID of the related contact.
          - name: engagement_id
            description: The ID of the related engagement.

      - name: engagement_email
        description: Each record represents an EMAIL engagement event.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_email_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: engagement_id
            description: The ID of the engagement.
          - name: property_hs_createdate
            description: >
              This field marks the email's time of creation and determines where the email sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: timestamp
            description: > 
              This field marks the email's time of occurrence and determines where the email sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_owner_id
            description: > 
              The ID of the owner associated with the email. This field determines the user listed as the email creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_team_id
            description: >
              The ID of the team associated with the email. This field determines the team listed as the email creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version.

      - name: engagement_email_cc
        description: Each record represents a CC'd email address as part of an EMAIL engagement.
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: email
            description: The email address of the recipient.
          - name: engagement_id
            description: The ID of the related engagement.
          - name: first_name
            description: The first name of the recipient.
          - name: last_name
            description: The last name of the recipient.

      - name: engagement_email_to
        description: Each record represents a TO email address as part of an EMAIL engagement.
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: email
            description: The email address of the recipient.
          - name: engagement_id
            description: The ID of the related engagement.
          - name: first_name
            description: The first name of the recipient.
          - name: last_name
            description: The last name of the recipient.

      - name: engagement_meeting
        description: Each record represents a MEETING engagement event.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_meeting_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: engagement_id
            description: The ID of the engagement.
          - name: property_hs_createdate
            description: >
              This field marks the meeting's time of creation and determines where the meeting sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: timestamp
            description: > 
              This field marks the meeting's time of occurrence and determines where the meeting sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_owner_id
            description: > 
              The ID of the owner associated with the meeting. This field determines the user listed as the meeting creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_team_id
            description: >
              The ID of the team associated with the meeting. This field determines the team listed as the meeting creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version.

      - name: engagement_note
        description: Each record represents a NOTE engagement event.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_note_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: body
            description: The body of the note. The body has a limit of 65536 characters.
          - name: engagement_id
            description: The ID of the engagement.
          - name: property_hs_createdate
            description: >
              This field marks the note's time of creation and determines where the note sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: timestamp
            description: > 
              This field marks the note's time of occurrence and determines where the note sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_owner_id
            description: > 
              The ID of the owner associated with the note. This field determines the user listed as the note creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_team_id
            description: >
              The ID of the team associated with the note. This field determines the team listed as the note creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version.

      - name: engagement_task
        description: Each record represents a TASK engagement event.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_engagement_enabled', true) and var('hubspot_engagement_task_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: engagement_id
            description: The ID of the engagement.
          - name: property_hs_createdate
            description: >
              This field marks the task's time of creation and determines where the task sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: timestamp
            description: > 
              This field marks the task's time of occurrence and determines where the task sits on the record timeline. You can use either a Unix timestamp in milliseconds or UTC format. 

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_owner_id
            description: > 
              The ID of the owner associated with the task. This field determines the user listed as the task creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version. For the pre HubSpot v3 versions, this value may be found within the parent `engagement` table.
          - name: property_hubspot_team_id
            description: >
              The ID of the team associated with the task. This field determines the team listed as the task creator on the record timeline.

              PLEASE NOTE: This field will only be populated for connectors utilizing the HubSpot v3 API version.

      - name: form
        description: Each record represents a Hubspot form.
        columns:
          - name: _fivetran_deleted
            description: '{{ doc("_fivetran_deleted") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: created_at
            description: A timestamp for when the form was created.
          - name: css_class
            description: The CSS classes assigned to the form.
          - name: follow_up_id
            description: This field is no longer used.
          - name: guid
            description: The internal ID of the form.
          - name: lead_nurturing_campaign_id
            description: TBD
          - name: method
            description: This field is no longer used.
          - name: name
            description: The name of the form.

          - name: notify_recipients
            description: |
              A comma-separated list of user IDs that should receive submission notifications.
              Email addresses will be returned for individuals who aren't users.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: redirect
            description: The URL that the visitor will be redirected to after filling out the form.
          - name: submit_text
            description: The text used for the submit button.
          - name: updated_at
            description: A timestamp for when the form was last updated.

      - name: owner
        description: Each record represents an owner/user in Hubspot.
        config:
          enabled: "{{ var('hubspot_sales_enabled', true) and var('hubspot_owner_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: created_at
            description: A timestamp for when the owner was created.
          - name: email
            description: The email address of the owner.
          - name: first_name
            description: The first name of the owner.
          - name: last_name
            description: The last name of the owner.
          - name: owner_id
            description: The ID of the owner.
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: type
            description: The type of owner.
          - name: updated_at
  
      - name: property
        description: Each record represents a property.
        config:
          enabled: "{{ var('hubspot_property_enabled', true) }}"
        columns:
          - name: _fivetran_id
            description: Fivetran generated id. Joins to `property_id` in the `property_option` table.
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: calculated
            description: Indicates if the property is calculated by a HubSpot process
          - name: created_at
            description: Timestamp representing when the property was created.
          - name: description
            description: A description of the property. 
          - name: field_type
            description: One of textarea, text, date, file, number, select, radio, checkbox, or booleancheckbox.
          - name: group_name
            description: The name of the property group that the property belongs to.
          - name: hubspot_defined
            description: This will be true for default properties that are built into HubSpot.
          - name: hubspot_object
            description: If this property is related to other objects, the object will be listed here.
          - name: label
            description: A human readable label for the property.
          - name: name
            description: The internal name of the property.
          - name: show_currency_symbol
            description: If true, the property will display the currency symbol set in the portal settings.
          - name: type
            description: One of string, number, date, datetime, or enumeration.
          - name: updated_at
            description: Timestamp representing when the property was last updated.

      - name: property_option
        description: Each record represents an option for the related property.
        config:
          enabled: "{{ var('hubspot_property_enabled', true) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: label
            description: The label of the option displayed inside the HubSpot app.
          - name: property_id
            description: The ID of the related property.
          - name: display_order
            description: Order of options displayed in Hubspot, starting with the lowest positive integer value. Values of -1 will cause the option to be displayed after any positive values.
          - name: hidden
            description: Boolean if the option will be displayed in HubSpot
          - name: value
            description: The internal value of the option.

      - name: ticket_company
        description: Each record represents a 'link' between a ticket and company.
        config:
          enabled: "{{ var('hubspot_service_enabled', false) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: ticket_id
            description: The ID of the related ticket.
          - name: company_id
            description: The ID of the related company.

      - name: ticket_contact
        description: Each record represents a 'link' between a ticket and a contact.
        config:
          enabled: "{{ var('hubspot_service_enabled', false) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: ticket_id
            description: The ID of the related ticket.
          - name: contact_id
            description: The ID of the related contact.

      - name: ticket_deal
        description: Each record represents a 'link' between a ticket and a deal.
        config:
          enabled: "{{ var('hubspot_service_enabled', false) and var('hubspot_ticket_deal_enabled', false) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: ticket_id
            description: The ID of the related ticket.
          - name: deal_id
            description: The ID of the related deal.

      - name: ticket_engagement
        description: Each record represents a 'link' between a ticket and an engagement.
        config:
          enabled: "{{ var('hubspot_service_enabled', false) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: ticket_id
            description: The ID of the related ticket.
          - name: engagement_id
            description: The ID of the related deal.
      
      - name: ticket_pipeline_stage
        description: Each record represents a ticket pipeline stage.
        config:
          enabled: "{{ var('hubspot_service_enabled', false) }}"
        columns:
          - name: _fivetran_deleted
            description: '{{ doc("_fivetran_deleted") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: active
            description: Boolean indicating whether the pipeline stage is active.
          - name: display_order
            description: Used to determine the order in which the stages appear when viewed in HubSpot.
          - name: is_closed
            description: Boolean indicating if the pipeline stage is closed.
          - name: label
            description: The human-readable label for the stage. The label is used when showing the stage in HubSpot.
          - name: pipeline_id
            description: The ID of the pipeline.
          - name: stage_id
            description: The ID of the pipeline stage.
          - name: ticket_state
            description: State of the ticket.
          - name: created_at
            description: A timestamp representing when the record was created.
          - name: updated_at
            description: A timestamp representing when the record was updated.

      - name: ticket_pipeline
        description: Each record represents a ticket pipeline.
        config:
          enabled: "{{ var('hubspot_service_enabled', false) }}"
        columns:
          - name: _fivetran_deleted
            description: '{{ doc("_fivetran_deleted") }}'
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: active
            description: Boolean indicating whether the pipeline is active.
          - name: display_order
            description: Used to determine the order in which the stages appear when viewed in HubSpot.
          - name: label
            description: The human-readable label for the stage. The label is used when showing the stage in HubSpot.
          - name: object_type_id
            description: Reference to the object type.
          - name: pipeline_id
            description: Reference to the pipeline.
          - name: created_at
            description: A timestamp representing when the record was created.
          - name: updated_at
            description: A timestamp representing when the record was updated.

      - name: ticket_property_history
        description: Each record represents a change to ticket record in Hubspot.
        config:
          enabled: "{{ var('hubspot_service_enabled', false) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: source
            description: '{{ doc("history_source") }}'
          - name: source_id
            description: '{{ doc("history_source_id") }}'
          - name: timestamp_instant
            description: '{{ doc("history_timestamp") }}'
          - name: ticket_id
            description: The ID of the related ticket record.
          - name: name
            description: '{{ doc("history_name") }}'
          - name: value
            description: '{{ doc("history_value") }}'

      - name: ticket
        description: Each record represents a ticket in Hubspot.
        config:
          enabled: "{{ var('hubspot_service_enabled', false) }}"
        columns:
          - name: _fivetran_synced
            description: '{{ doc("_fivetran_synced") }}'
          - name: id
            description: ID of the ticket.
          - name: is_deleted
            description: Whether the record was deleted (v2 endpoint).
          - name: _fivetran_deleted
            description: Whether the record was deleted (v3 endpoint).
          - name: portal_id
            description: '{{ doc("portal_id") }}'
          - name: property_closed_date
            description: The date the ticket was closed.
          - name: property_createdate
            description: The date the ticket was created.
          - name: property_first_agent_reply_date
            description: the date for the first agent reply on the ticket.
          - name: property_hs_pipeline
            description: The ID of the ticket's pipeline.
          - name: property_hs_pipeline_stage
            description: The ID of the ticket's pipeline stage.
          - name: property_hs_ticket_priority
            description: The priority of the ticket.
          - name: property_hs_ticket_category
            description: The category of the ticket.
          - name: property_hubspot_owner_id
            description: The ID of the deal's owner.
          - name: property_subject
            description: Short summary of ticket.
          - name: property_content
            description: Text in body of the ticket.
```
  </p></details>

2. Set the `has_defined_sources` variable (scoped to the `hubspot_source` package) to true, like such:
```yml
# dbt_project.yml
vars:
  hubspot_source:
    has_defined_sources: true
```

## Step 4: Disable models for non-existent sources
> _This step is unnecessary (but still available for use) if you are unioning multiple connectors together in the previous step. That is, the `union_data` macro we use will create completely empty staging models for sources that are not found in any of your Hubspot schemas/databases. However, you can still leverage the below variables if you would like to avoid this behavior._

When setting up your Hubspot connection in Fivetran, it is possible that not every table this package expects will be synced. This can occur because you either don't use that functionality in Hubspot or have actively decided to not sync some tables. In order to disable the relevant functionality in the package, you will need to add the relevant variables. By default, all variables are assumed to be `true` (with exception of `hubspot_service_enabled`, `hubspot_ticket_deal_enabled`, and `hubspot_contact_merge_audit_enabled`). You only need to add variables within your root `dbt_project.yml` for the tables you would like to disable or enable respectively:

```yml
vars:
  # Marketing

  hubspot_marketing_enabled: false                        # Disables all marketing models
  hubspot_contact_enabled: false                          # Disables the contact models
  hubspot_contact_list_enabled: false                     # Disables contact list models
  hubspot_contact_list_member_enabled: false              # Disables contact list member models
  hubspot_contact_property_enabled: false                 # Disables the contact property models
  hubspot_contact_property_history_enabled: false         # Disables the contact property history models
  hubspot_email_event_enabled: false                      # Disables all email_event models and functionality
  hubspot_email_event_bounce_enabled: false
  hubspot_email_event_click_enabled: false
  hubspot_email_event_deferred_enabled: false
  hubspot_email_event_delivered_enabled: false
  hubspot_email_event_dropped_enabled: false
  hubspot_email_event_forward_enabled: false
  hubspot_email_event_open_enabled: false
  hubspot_email_event_print_enabled: false
  hubspot_email_event_sent_enabled: false
  hubspot_email_event_spam_report_enabled: false
  hubspot_email_event_status_change_enabled: false

  hubspot_contact_merge_audit_enabled: true               # Enables the use of the CONTACT_MERGE_AUDIT table (deprecated by Hubspot v3 API) for removing merged contacts in the final models.
                                                          # If false, ~~~contacts will still be merged~~~, but using the CONTACT.property_hs_calculated_merged_vids field (introduced in v3 of the Hubspot CRM API)
                                                          # Default = false

  # Sales

  hubspot_sales_enabled: false                            # Disables all sales models
  hubspot_company_enabled: false
  hubspot_company_property_history_enabled: false         # Disables the company property history models
  hubspot_deal_enabled: false
  hubspot_deal_company_enabled: false
  hubspot_deal_contact_enabled: false
  hubspot_deal_property_history_enabled: false            # Disables the deal property history models
  hubspot_engagement_enabled: false                       # Disables all engagement models and functionality
  hubspot_engagement_contact_enabled: false
  hubspot_engagement_company_enabled: false
  hubspot_engagement_deal_enabled: false
  hubspot_engagement_call_enabled: false
  hubspot_engagement_email_enabled: false
  hubspot_engagement_meeting_enabled: false
  hubspot_engagement_note_enabled: false
  hubspot_engagement_task_enabled: false
  hubspot_owner_enabled: false
  hubspot_property_enabled: false                         # Disables property and property_option tables
  
  # Service
  hubspot_service_enabled: true                           # Enables all service/ticket models. Default = false
  hubspot_ticket_deal_enabled: true                       # Default = false
```

## (Optional) Step 5: Additional configurations
<details open><summary>Expand/collapse configurations</summary>

### Configure email metrics
This package allows you to specify which email metrics (total count and total unique count) you would like to be calculated for specified fields within the `hubspot__email_campaigns` model. By default, the `email_metrics` variable below includes all the shown fields. If you would like to remove any field metrics from the final model, you may copy and paste the below snippet within your root `dbt_project.yml` and remove any fields you want to be ignored in the final model.

```yml
vars:
  email_metrics: ['bounces',      #Remove if you do not want metrics in final model.
                  'clicks',       #Remove if you do not want metrics in final model.
                  'deferrals',    #Remove if you do not want metrics in final model.
                  'deliveries',   #Remove if you do not want metrics in final model.
                  'drops',        #Remove if you do not want metrics in final model.
                  'forwards',     #Remove if you do not want metrics in final model.
                  'opens',        #Remove if you do not want metrics in final model.
                  'prints',       #Remove if you do not want metrics in final model.
                  'spam_reports', #Remove if you do not want metrics in final model.
                  'unsubscribes'  #Remove if you do not want metrics in final model.
                  ]
```
### Include passthrough columns
This package includes all source columns defined in the macros folder. We highly recommend including custom fields in this package as models now only bring in a few fields for the `company`, `contact`, `deal`, and `ticket` tables. You can add more columns using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables in your root `dbt_project.yml`.

```yml
vars:
  hubspot__deal_pass_through_columns:
    - name:           "property_field_new_id"
      alias:          "new_name_for_this_field_id"
      transform_sql:  "cast(new_name_for_this_field as int64)"
    - name:           "this_other_field"
      transform_sql:  "cast(this_other_field as string)"
  hubspot__contact_pass_through_columns:
    - name:           "wow_i_can_add_all_my_custom_fields"
      alias:          "best_field"
  hubspot__company_pass_through_columns:
    - name:           "this_is_radical"
      alias:          "radical_field"
      transform_sql:  "cast(radical_field as string)"
  hubspot__ticket_pass_through_columns:
    - name:           "property_mmm"
      alias:          "mmm"
    - name:           "property_bop"
      alias:          "bop"
```
**Alternatively**, if you would like to simply pass through **all columns** in the above four tables, add the following configuration to your dbt_project.yml. Note that this will override any `hubspot__[table_name]_pass_through_columns` variables.

```yml
vars:
  hubspot__pass_through_all_columns: true # default is false
```
### Adding property label
For `property_hs_*` columns, you can enable the corresponding, human-readable `property_option`.`label` to be included in the staging models. 

#### Important! 
- You must have sources `property` and `property_option` enabled to enable labels. By default, these sources are enabled.  
- You CANNOT enable labels if using `hubspot__pass_through_all_columns: true`.
- We recommend being selective with the label columns you add. As you add more label columns, your run time will increase due to the underlying logic requirements.

To enable labels for a given property, set the property attribute `add_property_label: true`, using the below format.

```yml
vars:
  hubspot__ticket_pass_through_columns:
    - name: "property_hs_fieldname"
      alias: "fieldname"
      add_property_label: true
```
  Alternatively, you can enable labels for all passthrough properties by using variable `hubspot__enable_all_property_labels: true`, formatted like the below example. 

```yml
vars:
  hubspot__enable_all_property_labels: true
  hubspot__ticket_pass_through_columns:
    - name: "property_hs_fieldname1"
    - name: "property_hs_fieldname2"
```

### Including calculated fields
This package also provides the ability to pass calculated fields through to the `company`, `contact`, `deal`, and `ticket` staging models. If you would like to add a calculated field to any of the mentioned staging models, you may configure the respective `hubspot__[table_name]_calculated_fields` variables with the `name` of the field you would like to create, and the `transform_sql` which will be the actual calculation that will make up the calculated field.
```yml
vars:
  hubspot__deal_calculated_fields:
    - name:          "deal_calculated_field"
      transform_sql: "existing_field * other_field"
  hubspot__company_calculated_fields:
    - name:          "company_calculated_field"
      transform_sql: "concat(name_field, '_company_name')"
  hubspot__contact_calculated_fields:
    - name:          "contact_calculated_field"
      transform_sql: "contact_revenue - contact_expense"
  hubspot__ticket_calculated_fields:
    - name:          "ticket_calculated_field"
      transform_sql: "total_field / other_total_field"
```
### Filtering email events
When leveraging email events, HubSpot customers may take advantage of filtering out specified email events. These filtered email events are present within the `stg_hubspot__email_events` model and are identified by the `is_filtered_event` boolean field. By default, these events are included in the staging and downstream models generated from this package. However, if you wish to remove these filtered events you may do so by setting the `hubspot_using_all_email_events` variable to false. See below for exact configurations you may provide in your `dbt_project.yml` file:
```yml
vars:
  hubspot_using_all_email_events: false # True by default
```

### Daily ticket history
The `hubspot__daily_ticket_history` model is disabled by default, but will materialize if `hubspot_service_enabled` is set to `true`. See additional configurations for this model below.

> **Note**: `hubspot__daily_ticket_history` and its parent intermediate models are incremental. After making any of the below configurations, you will need to run a full refresh.

#### **Tracking ticket properties**
By default, `hubspot__daily_ticket_history` will track each ticket's state, pipeline, and pipeline stage and pivot these properties into columns. However, any property from the source `TICKET_PROPERTY_HISTORY` table can be tracked and pivoted out into columns. To add other properties to this end model, add the following configuration to your `dbt_project.yml` file:

```yml
vars:
  hubspot__ticket_property_history_columns:
    - the
    - list
    - of 
    - property
    - names
```

#### **Extending ticket history past closing date**
This package will create a row in `hubspot__daily_ticket_history` for each day that a ticket is open, starting at its creation date. A Hubspot ticket can be altered after being closed, so its properties can change after this date.

By default, the package will track a ticket up to its closing date (or the current date if still open). To capture post-closure changes, you may want to extend a ticket's history past the close date. To do so, add the following configuration to your root dbt_project.yml file:

```yml
vars:
  hubspot:
    ticket_history_extension_days: integer_number_of_days # default = 0
```

### Changing the Build Schema
By default this package will build the HubSpot staging models within a schema titled (<target_schema> + `_stg_hubspot`) and HubSpot final models within a schema titled (<target_schema> + `hubspot`) in your target database. If this is not where you would like your modeled HubSpot data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    hubspot:
      +schema: my_new_schema_name # leave blank for just the target_schema
    hubspot_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_hubspot_source/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    hubspot_<default_source_table_name>_identifier: your_table_name
```
</details>

## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core™ setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/hubspot_source
      version: [">=0.15.0", "<0.16.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/hubspot/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_hubspot/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions!

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_hubspot/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to be part of the community discourse? Create a post in the [Fivetran community](https://community.fivetran.com/t5/user-group-for-dbt/gh-p/dbt-user-group) and our team along with the community can join in on the discussion!
