-- ============================================
-- AirOps Intelligence
-- FAA Airports - RAW (Bronze) ingestion
--
-- Source:
-- s3://airops-data-platform-adamb/landing/airports/cycle=YYYY-MM-DD/APT_BASE.csv
--
-- Safe to re-run:
--   - table is only created if missing
--   - COPY skips files that were already loaded
-- ============================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE AIR_OPS_WH;
USE DATABASE AIR_OPS;
USE SCHEMA RAW;


-- --------------------------------------------
-- 1. File format
--
-- ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE is needed
-- because the table has 3 extra metadata columns
-- that do not exist in the file.
-- --------------------------------------------

CREATE OR REPLACE FILE FORMAT FAA_CSV_HEADER_FORMAT
    TYPE = CSV
    PARSE_HEADER = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('', 'NULL')
    EMPTY_FIELD_AS_NULL = TRUE
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- --------------------------------------------
-- 2. External stage
-- Covers every FAA cycle folder under landing/airports/
-- --------------------------------------------

CREATE OR REPLACE STAGE FAA_AIRPORTS_STAGE
    URL = 's3://airops-data-platform-adamb/landing/airports/'
    STORAGE_INTEGRATION = AIR_OPS_S3_INT
    FILE_FORMAT = FAA_CSV_HEADER_FORMAT;


LIST @FAA_AIRPORTS_STAGE;


-- --------------------------------------------
-- 3. RAW table
--
-- Column names come from the file header via
-- INFER_SCHEMA. Every column is forced to VARCHAR
-- and NULLABLE so Bronze keeps the source values
-- unchanged (e.g. SITE_NO '00103.' keeps its
-- leading zeros). Typing happens in Silver.
-- --------------------------------------------

CREATE TABLE IF NOT EXISTS AIR_OPS.RAW.AIRPORTS
USING TEMPLATE (
    SELECT ARRAY_AGG(
        OBJECT_CONSTRUCT(
            'COLUMN_NAME', COLUMN_NAME,
            'TYPE', 'VARCHAR',
            'NULLABLE', TRUE
        )
    ) WITHIN GROUP (ORDER BY ORDER_ID)
    FROM TABLE(
        INFER_SCHEMA(
            LOCATION => '@AIR_OPS.RAW.FAA_AIRPORTS_STAGE/cycle=2026-10-01/',
            FILES => 'APT_BASE.csv',
            FILE_FORMAT => 'AIR_OPS.RAW.FAA_CSV_HEADER_FORMAT'
        )
    )
);

ALTER TABLE AIR_OPS.RAW.AIRPORTS
ADD COLUMN IF NOT EXISTS _SOURCE_FILE STRING;

ALTER TABLE AIR_OPS.RAW.AIRPORTS
ADD COLUMN IF NOT EXISTS _INGESTED_AT TIMESTAMP_LTZ;

ALTER TABLE AIR_OPS.RAW.AIRPORTS
ADD COLUMN IF NOT EXISTS _FILE_LAST_MODIFIED TIMESTAMP_LTZ;


-- --------------------------------------------
-- 4. Load
-- PATTERN limits the load to APT_BASE files so other
-- FAA files landed later are not loaded here.
-- --------------------------------------------

COPY INTO AIR_OPS.RAW.AIRPORTS
FROM @AIR_OPS.RAW.FAA_AIRPORTS_STAGE
PATTERN = '.*cycle=[0-9-]+/APT_BASE[.]csv'
FILE_FORMAT = (
    FORMAT_NAME = 'AIR_OPS.RAW.FAA_CSV_HEADER_FORMAT'
)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE

INCLUDE_METADATA = (
    _SOURCE_FILE = METADATA$FILENAME,
    _INGESTED_AT = METADATA$START_SCAN_TIME,
    _FILE_LAST_MODIFIED = METADATA$FILE_LAST_MODIFIED
)

ON_ERROR = 'ABORT_STATEMENT';


-- --------------------------------------------
-- 5. Verify
-- Expected for cycle 2026-10-01: 19,427 rows
-- --------------------------------------------

SELECT
    _SOURCE_FILE,
    EFF_DATE,
    COUNT(*) AS row_count,
    MIN(_INGESTED_AT) AS ingested_at
FROM AIR_OPS.RAW.AIRPORTS
GROUP BY _SOURCE_FILE, EFF_DATE
ORDER BY _SOURCE_FILE;
