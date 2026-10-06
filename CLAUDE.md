# AirOps Intelligence

## Project Goal

Build a production-style airline operations data platform using
public aviation, weather, airport, and fuel-price datasets.

## Technology Stack

- Python
- Apache Airflow
- AWS S3
- Snowflake
- dbt Core
- Streamlit
- Snowflake Cortex

## Architecture

Sources
→ Airflow
→ AWS S3
→ Snowflake Bronze
→ dbt Silver
→ Core Data Warehouse
→ Gold Data Marts
→ Streamlit / AI Data Products

## Engineering Rules

1. Raw source data must remain unchanged in Bronze.
2. Business transformations belong in Silver or downstream models.
3. Pipelines must support incremental processing.
4. Never hardcode passwords or credentials.
5. Add logging and error handling to ingestion code.
6. Add data-quality checks to new pipelines.
7. Failed quality records should be traceable.
8. dbt Core is used for transformations.
9. Airflow is the primary orchestration platform.
10. Snowflake is the analytical warehouse.
11. Use clear modular Python functions.
12. Code should be production-style but easy to understand.
13. Do not introduce unnecessary tools or frameworks.

## Data Layers

### Bronze
Raw source-aligned data plus ingestion metadata.

### Silver
Cleaned, typed, standardized and deduplicated data.

### Core
Dimensional enterprise data warehouse.

### Gold
Business-facing analytical marts.

## Data Quality

Quality checks should distinguish between:

- true data errors
- expected NULL values
- business-condition-dependent NULL values

For example, ArrDelay may legitimately be NULL for cancelled or diverted flights.