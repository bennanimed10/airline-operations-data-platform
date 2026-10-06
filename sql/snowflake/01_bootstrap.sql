
-- --------------------------------------------
-- 1. Warehouse
-- --------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS AIR_OPS_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;


USE WAREHOUSE AIR_OPS_WH;


-- --------------------------------------------
-- 2. Database
-- --------------------------------------------

CREATE DATABASE IF NOT EXISTS AIR_OPS;


USE DATABASE AIR_OPS;


-- --------------------------------------------
-- 3. Schemas
-- --------------------------------------------

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS SILVER;
CREATE SCHEMA IF NOT EXISTS CORE;
CREATE SCHEMA IF NOT EXISTS MARTS;
CREATE SCHEMA IF NOT EXISTS AUDIT;


-- --------------------------------------------
-- 4. File format for BTS CSV
-- --------------------------------------------

CREATE OR REPLACE FILE FORMAT RAW.BTS_CSV_FORMAT
    TYPE = CSV
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    NULL_IF = ('', 'NULL')
    EMPTY_FIELD_AS_NULL = TRUE
    TRIM_SPACE = TRUE;


-- --------------------------------------------
-- 5. Verify
-- --------------------------------------------

SHOW SCHEMAS IN DATABASE AIR_OPS;

SHOW WAREHOUSES LIKE 'AIR_OPS_WH';