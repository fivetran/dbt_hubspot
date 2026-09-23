# Decision Log

## BigQuery partition granularity differs across daily history models

**Decision**: Contact, deal, and company daily history models use `granularity: 'month'` in their BigQuery `partition_by` config. Ticket history models use the default `granularity: 'day'`.

**Why**: Ticket volumes are typically much lower than contacts, deals, and companies. The contact, deal, and company history tables accumulate enough daily rows that day-level partitioning produces a large number of partitions, increasing metadata overhead and query cost. Month-level partitioning reduces partition count while keeping incremental run performance acceptable. Ticket history does not share this scale concern, so day-level partitioning is retained there to preserve fine-grained partition pruning for incremental runs.

**Scope**: `granularity` is a BigQuery-only config key. It has no effect on other supported warehouses (Snowflake, Redshift, Databricks, DuckDB, Postgres).
