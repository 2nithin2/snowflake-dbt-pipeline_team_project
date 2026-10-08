-- =============================================================================
-- File: 01_schemas_and_grants.sql
-- Description: Sets up the medallion/analytics data layers within the active 
--              database and configures granular schema and object permissions 
--              for transformation (dbt) and ingestion (ADF) roles.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Step 1: Provision Medallion & Mart Schemas
-- -----------------------------------------------------------------------------
-- Raw landing schema for source data ingested directly from external tools
CREATE SCHEMA IF NOT EXISTS RAW_SM;

-- Staging layer for initial cleansing, type casting, and standardized views
CREATE SCHEMA IF NOT EXISTS STAGE_SM;

-- Intermediate layer for cross-source joins and complex business transformations
CREATE SCHEMA IF NOT EXISTS INTERMEDIATE_SM;

-- Consumption/presentation layer hosting final fact and dimension models
CREATE SCHEMA IF NOT EXISTS MARTS;

-- -----------------------------------------------------------------------------
-- Step 2: Role Permissions - TRANSFORMER (dbt)
-- -----------------------------------------------------------------------------
-- Grant read-only access to source raw tables (current and future)
GRANT USAGE ON SCHEMA RAW_SM TO ROLE TRANSFORMER;
GRANT SELECT ON ALL TABLES IN SCHEMA RAW_SM TO ROLE TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA RAW_SM TO ROLE TRANSFORMER;

-- Grant full model build privileges (CREATE, MODIFY, DROP) in downstream layers
GRANT ALL ON SCHEMA STAGE_SM TO ROLE TRANSFORMER;
GRANT ALL ON SCHEMA INTERMEDIATE_SM TO ROLE TRANSFORMER;
GRANT ALL ON SCHEMA MARTS TO ROLE TRANSFORMER;

-- -----------------------------------------------------------------------------
-- Step 3: Role Permissions - ADF_LOADER (Ingestion Pipeline)
-- -----------------------------------------------------------------------------
-- Allow data ingestion pipelines to write into the raw landing tables
GRANT USAGE ON SCHEMA RAW_SM TO ROLE ADF_LOADER;
GRANT INSERT ON ALL TABLES IN SCHEMA RAW_SM TO ROLE ADF_LOADER;
GRANT INSERT ON FUTURE TABLES IN SCHEMA RAW_SM TO ROLE ADF_LOADER;