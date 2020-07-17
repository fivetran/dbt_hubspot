# Hubspot 

This package models Hubspot data from [Fivetran's connector](https://fivetran.com/docs/applications/hubspot). It uses data in the format described by the [marketing](https://docs.google.com/presentation/d/1hrPp310SNK2qyESCV_g_JFx_Knm1MwB467wN3dEgy0M/edit#slide=id.g244d368397_0_1) and [sales](https://docs.google.com/presentation/d/1KABQnt8WmtZe7u5l7WFUoPIsWzv63P9gsWF79XGLoZE/edit#slide=id.g244d368397_0_1) ERDs.

This package enables you to better understand your Hubspot email and engagement performance. The output includes models for contacts, companies, and deals with enriched email and engagement metrics. It also includes analysis-ready event tables for email and engagement activities.

## Models

This package contains transformation models, designed to work simultaneously with our [Hubspot source package](https://github.com/fivetran/dbt_hubspot_source). A depenedency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                      |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| hubspot__companies       | Each record represents a company in Hubspot, enriched with metrics about engagement activities.                      |
| hubspot__company_history | Each record represents a change to a company in Hubspot, with `valid_to` and `valid_from` information.               |
| hubspot__contacts        | Each record represents a contact in Hubspot, enriched with metrics about email and engagement activities.            |
| hubspot__contact_history | Each record represents a change to a contact in Hubspot, with `valid_to` and `valid_from` information.               |
| hubspot__contact_lists   | Each record represents a contact list in Hubspot, enriched with metrics about email activities.                      |
| hubspot__deal            | Each record represents a deal in Hubspot, enriched with metrics about engagement activities.                         |
| hubspot__deal_history    | Each record represents a change to a deal in Hubspot, with `valid_to` and `valid_from` information.                  |
| hubspot__email_campaigns | Each record represents a email campaign in Hubspot, enriched with metrics about email activities.                    |
| hubspot__email_event_*   | Each record represents an email event in Hubspot, joined with relevant tables to make them analysis-ready.           |
| hubspot__email_sends     | Each record represents a sent email in Hubspot, enriched with metrics about opens, clicks, and other email activity. |
| hubspot__engagement_*    | Each record represents an engagement event in Hubspot, joined with relevant tables to make them analysis-ready.      |

## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

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

When setting up your Hubspot connection in Fivetran, it is possible that not every table this package expects will be synced. This can occur because you either don't use that functionality in Hubspot or have actively decided to not sync some tables. In order to disable the relevant functionality in the package, you will need to add the relevant variables. By default, all variables are assumed to be `true`. You only need to add variables for the tables you would like to disable:  

```yml
# dbt_project.yml

...
config-version: 2

vars:
  hubspot_source:

    # Marketing

    hubspot_marketing_enabled: false                        # Disables all marketing models 
    hubspot_email_event_enabled: false                      # Disables all email_event models and functionality
    hubspot_email_event_bounce_enabled: false
    hubspot_email_event_click_enabled: false
    hubspot_email_event_deferred_enabled: false
    hubspot_email_event_delivered_enabled: false
    hubspot_email_event_dropped_enabled: false
    hubspot_email_event_forward_enabled: false
    hubspot_email_event_click_enabled: false
    hubspot_email_event_opens_enabled: false
    hubspot_email_event_print_enabled: false
    hubspot_email_event_sent_enabled: false
    hubspot_email_event_spam_report: false
    hubspot_email_event_status_change_enabled: false

    # Sales

    hubspot_sales_enabled: false                            # Disables all sales models
    hubspot_company_enabled: false
    hubspot_deal_enabled: false
    hubspot_engagement_enabled: false                       # Disables all engagement models and functionality
    hubspot_engagement_contact_enabled: false
    hubspot_engagement_company_enabled: false
    hubspot_engagement_deal_enabled: false
    hubspot_engagement_calls_enabled: false
    hubspot_engagement_emails_enabled: false
    hubspot_engagement_meetings_enabled: false
    hubspot_engagement_notes_enabled: false
    hubspot_engagement_tasks_enabled: false
```

## Contributions

Additional contributions to this package are very welcome! Please create issues
or open PRs against `master`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Resources:
- Learn more about Fivetran [here](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices