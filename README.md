[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 
# Hubspot 

This package models Hubspot data from [Fivetran's connector](https://fivetran.com/docs/applications/hubspot). It uses data in the format described by the [marketing](https://docs.google.com/presentation/d/1hrPp310SNK2qyESCV_g_JFx_Knm1MwB467wN3dEgy0M/edit#slide=id.g244d368397_0_1) and [sales](https://docs.google.com/presentation/d/1KABQnt8WmtZe7u5l7WFUoPIsWzv63P9gsWF79XGLoZE/edit#slide=id.g244d368397_0_1) ERDs.

This package enables you to better understand your Hubspot email and engagement performance. The output includes models for contacts, companies, and deals with enriched email and engagement metrics. It also includes analysis-ready event tables for email and engagement activities.

## Models

This package contains transformation models, designed to work simultaneously with our [Hubspot source package](https://github.com/fivetran/dbt_hubspot_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                      |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| [hubspot__companies](models/sales/hubspot__companies.sql)         | Each record represents a company in Hubspot, enriched with metrics about engagement activities.                      |
| [hubspot__company_history](models/sales/history/hubspot__company_history.sql) | Each record represents a change to a company in Hubspot, with `valid_to` and `valid_from` information.               |
| [hubspot__contacts](models/marketing/hubspot__contacts.sql)        | Each record represents a contact in Hubspot, enriched with metrics about email and engagement activities.            |
| [hubspot__contact_history](models/marketing/history/hubspot__contact_history.sql) | Each record represents a change to a contact in Hubspot, with `valid_to` and `valid_from` information.               |
| [hubspot__contact_lists](models/marketing/hubspot__contact_lists.sql)   | Each record represents a contact list in Hubspot, enriched with metrics about email activities.                      |
| [hubspot__deals](models/sales/hubspot__deals.sql)            | Each record represents a deal in Hubspot, enriched with metrics about engagement activities.                         |
| [hubspot__deal_stages](models/sales/hubspot__deal_stages.sql)            | Each record represents a deal stage in Hubspot, enriched with metrics deal activities.                         |
| [hubspot__deal_history](models/sales/history/hubspot__deal_history.sql)    | Each record represents a change to a deal in Hubspot, with `valid_to` and `valid_from` information.                  |
| [hubspot__email_campaigns](models/marketing/hubspot__email_campaigns.sql) | Each record represents a email campaign in Hubspot, enriched with metrics about email activities.                    |
| [hubspot__email_event_*](models/marketing/email_events/)   | Each record represents an email event in Hubspot, joined with relevant tables to make them analysis-ready.           |
| [hubspot__email_sends](models/marketing/hubspot__email_sends.sql)     | Each record represents a sent email in Hubspot, enriched with metrics about opens, clicks, and other email activity. |
| [hubspot__engagement_*](models/sales/engagement_events/)    | Each record represents an engagement event in Hubspot, joined with relevant tables to make them analysis-ready.      |

## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

Include in your `packages.yml`

```yaml
packages:
  - package: fivetran/hubspot
    version: [">=0.5.0", "<0.6.0"]
```

## Configuration
By default this package will look for your Hubspot data in the `hubspot` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Hubspot data is, please add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
config-version: 2

vars:
  hubspot_source:
    hubspot_database: your_database_name
    hubspot_schema: your_schema_name 
```

For additional configurations for the source models, please visit the [Hubspot source package](https://github.com/fivetran/dbt_hubspot_source).

### Disabling models

When setting up your Hubspot connection in Fivetran, it is possible that not every table this package expects will be synced. This can occur because you either don't use that functionality in Hubspot or have actively decided to not sync some tables. In order to disable the relevant functionality in the package, you will need to add the relevant variables. By default, all variables are assumed to be `true` (with exception of `hubspot_contact_merge_audit_enabled`). You only need to add variables for the tables you would like to disable or enable respectively:

```yml
# dbt_project.yml

...
config-version: 2

vars:

  # Marketing

  hubspot_marketing_enabled: false                        # Disables all marketing models
  hubspot_contact_enabled: false                          # Disables the contact models
  hubspot_contact_list_enabled: false                     # Disables contact list models
  hubspot_contact_list_member_enabled: false              # Disables contact list member models
  hubspot_contact_property_enabled: false                 # Disables the contact property models
  hubspot_email_event_enabled: false                      # Disables all email_event models and functionality
  hubspot_email_event_bounce_enabled: false
  hubspot_email_event_deferred_enabled: false
  hubspot_email_event_delivered_enabled: false
  hubspot_email_event_dropped_enabled: false
  hubspot_email_event_forward_enabled: false
  hubspot_email_event_click_enabled: false
  hubspot_email_event_open_enabled: false
  hubspot_email_event_print_enabled: false
  hubspot_email_event_sent_enabled: false
  hubspot_email_event_spam_report_enabled: false
  hubspot_email_event_status_change_enabled: false
  
  hubspot_contact_merge_audit_enabled: true               # Enables contact merge auditing to be applied to final models (removes any merged contacts that are still persisting in the contact table)

  # Sales

  hubspot_sales_enabled: false                            # Disables all sales models
  hubspot_company_enabled: false
  hubspot_deal_enabled: false
  hubspot_deal_company_enabled: false
  hubspot_deal_contact_enabled: false
  hubspot_engagement_enabled: false                       # Disables all engagement models and functionality
  hubspot_engagement_contact_enabled: false
  hubspot_engagement_company_enabled: false
  hubspot_engagement_deal_enabled: false
  hubspot_engagement_call_enabled: false
  hubspot_engagement_email_enabled: false
  hubspot_engagement_meeting_enabled: false
  hubspot_engagement_note_enabled: false
  hubspot_engagement_task_enabled: false
```


### Email Metrics
This package allows you to specify which email metrics (total count and total unique count) you would like to be calculated for specified fields within the `hubspot__email_campaigns` model. By default, the `email_metrics` variable below includes all the shown fields. If you would like to remove any field metrics from the final model, you may copy and paste the below snippet and remove any fields you want to be ignored in the final model.

```yml
# dbt_project.yml

...
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

### Passthrough Columns
Additionally, this package includes all source columns defined in the macros folder. We highly recommend including custom fields in this package as models now only bring in a few fields for the `company`, `contact`, `deal`, and `ticket` tables. You can add more columns using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables.

```yml
# dbt_project.yml

...
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

### Changing the Build Schema
By default this package will build the HubSpot staging models within a schema titled (<target_schema> + `_stg_hubspot`) and HubSpot final models within a schema titled (<target_schema> + `hubspot`) in your target database. If this is not where you would like your modeled HubSpot data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
models:
    hubspot:
      +schema: my_new_schema_name # leave blank for just the target_schema
    hubspot_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

## Database Support
This package has been tested on BigQuery, Snowflake, Redshift, and Postgres.

## Contributions

Additional contributions to this package are very welcome! Please create issues
or open PRs against `main`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Resources:
- Provide [feedback](https://www.surveymonkey.com/r/DQ7K7WW) on our existing dbt packages or what you'd like to see next
- Have questions, feedback, or need help? Book a time during our office hours [using Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com
- Find all of Fivetran's pre-built dbt packages in our [dbt hub](https://hub.getdbt.com/fivetran/)
- Learn how to orchestrate your models with [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt)
- Learn more about Fivetran overall [in our docs](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the dbt docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the dbt blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
