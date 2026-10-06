-- ============================================
-- AirOps Intelligence
-- dbt Role + Privileges
-- ============================================

USE ROLE ACCOUNTADMIN;


-- --------------------------------------------
-- 1. Create dedicated dbt role
-- --------------------------------------------

CREATE ROLE IF NOT EXISTS AIR_OPS_DBT_ROLE;


-- --------------------------------------------
-- 2. Allow dbt to use the warehouse
-- --------------------------------------------

GRANT USAGE
ON WAREHOUSE AIR_OPS_WH
TO ROLE AIR_OPS_DBT_ROLE;


-- --------------------------------------------
-- 3. Allow access to database
-- --------------------------------------------

GRANT USAGE
ON DATABASE AIR_OPS
TO ROLE AIR_OPS_DBT_ROLE;


-- --------------------------------------------
-- 4. RAW
-- dbt can READ Bronze, but should not modify it
-- --------------------------------------------

GRANT USAGE
ON SCHEMA AIR_OPS.RAW
TO ROLE AIR_OPS_DBT_ROLE;

GRANT SELECT
ON ALL TABLES IN SCHEMA AIR_OPS.RAW
TO ROLE AIR_OPS_DBT_ROLE;

GRANT SELECT
ON FUTURE TABLES IN SCHEMA AIR_OPS.RAW
TO ROLE AIR_OPS_DBT_ROLE;


-- --------------------------------------------
-- 5. SILVER
-- dbt can create models here
-- --------------------------------------------

GRANT USAGE
ON SCHEMA AIR_OPS.SILVER
TO ROLE AIR_OPS_DBT_ROLE;

GRANT CREATE TABLE,
      CREATE VIEW
ON SCHEMA AIR_OPS.SILVER
TO ROLE AIR_OPS_DBT_ROLE;


-- Existing dbt objects
GRANT SELECT,
      INSERT,
      UPDATE,
      DELETE,
      TRUNCATE
ON ALL TABLES IN SCHEMA AIR_OPS.SILVER
TO ROLE AIR_OPS_DBT_ROLE;


-- --------------------------------------------
-- 6. CORE
-- Future dimensional warehouse
-- --------------------------------------------

GRANT USAGE
ON SCHEMA AIR_OPS.CORE
TO ROLE AIR_OPS_DBT_ROLE;

GRANT CREATE TABLE,
      CREATE VIEW
ON SCHEMA AIR_OPS.CORE
TO ROLE AIR_OPS_DBT_ROLE;


-- --------------------------------------------
-- 7. MARTS
-- Future Gold layer
-- --------------------------------------------

GRANT USAGE
ON SCHEMA AIR_OPS.MARTS
TO ROLE AIR_OPS_DBT_ROLE;

GRANT CREATE TABLE,
      CREATE VIEW
ON SCHEMA AIR_OPS.MARTS
TO ROLE AIR_OPS_DBT_ROLE;


-- --------------------------------------------
-- 8. AUDIT
-- Allow dbt to read audit information
-- --------------------------------------------

GRANT USAGE
ON SCHEMA AIR_OPS.AUDIT
TO ROLE AIR_OPS_DBT_ROLE;

GRANT SELECT
ON ALL TABLES IN SCHEMA AIR_OPS.AUDIT
TO ROLE AIR_OPS_DBT_ROLE;

GRANT SELECT
ON FUTURE TABLES IN SCHEMA AIR_OPS.AUDIT
TO ROLE AIR_OPS_DBT_ROLE;


-- --------------------------------------------
-- 9. Give role to our Snowflake user
-- --------------------------------------------

GRANT ROLE AIR_OPS_DBT_ROLE
TO USER FLOWSHEET_DEV;