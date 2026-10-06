### Industry-Standard File Name

* **`00_account_setup.sql`** (Matches the naming convention used in the video repo)
* **`00_snowflake_bootstrap.sql`**
* **`00_init_account_and_rbac.sql`**

---

### Code with Descriptive Comments

```sql
-- =============================================================================
-- File: 00_account_setup.sql
-- Description: Initializes core account infrastructure across DEV, TEST, and PROD.
--              Provisions compute warehouses, storage databases, and RBAC roles 
--              (TRANSFORMER for dbt, ADF_LOADER for Azure Data Factory).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Step 1: Compute Warehouses Provisioning
-- -----------------------------------------------------------------------------
-- Create virtual warehouses with auto-suspend policies to manage compute costs
CREATE WAREHOUSE IF NOT EXISTS ANALYTICS_WH_DEV  
    WITH WAREHOUSE_SIZE = 'XSMALL' 
    AUTO_SUSPEND = 60;

CREATE WAREHOUSE IF NOT EXISTS ANALYTICS_WH_TEST 
    WITH WAREHOUSE_SIZE = 'XSMALL' 
    AUTO_SUSPEND = 60;

CREATE WAREHOUSE IF NOT EXISTS ANALYTICS_WH_PROD 
    WITH WAREHOUSE_SIZE = 'SMALL'  
    AUTO_SUSPEND = 120;

-- -----------------------------------------------------------------------------
-- Step 2: Database Provisioning
-- -----------------------------------------------------------------------------
-- Provision multi-environment databases for data isolation
CREATE DATABASE IF NOT EXISTS ANALYTICS_DB_DEV;
CREATE DATABASE IF NOT EXISTS ANALYTICS_DB_TEST;
CREATE DATABASE IF NOT EXISTS ANALYTICS_DB_PROD;

-- -----------------------------------------------------------------------------
-- Step 3: RBAC - Transformation Role (dbt)
-- -----------------------------------------------------------------------------
-- Create role responsible for modeling and schema builds
CREATE ROLE IF NOT EXISTS TRANSFORMER;

-- Grant warehouse usage for query execution across all environments
GRANT USAGE ON WAREHOUSE ANALYTICS_WH_DEV  TO ROLE TRANSFORMER;
GRANT USAGE ON WAREHOUSE ANALYTICS_WH_TEST TO ROLE TRANSFORMER;
GRANT USAGE ON WAREHOUSE ANALYTICS_WH_PROD TO ROLE TRANSFORMER;

-- Grant database visibility across all environments
GRANT USAGE ON DATABASE ANALYTICS_DB_DEV  TO ROLE TRANSFORMER;
GRANT USAGE ON DATABASE ANALYTICS_DB_TEST TO ROLE TRANSFORMER;
GRANT USAGE ON DATABASE ANALYTICS_DB_PROD TO ROLE TRANSFORMER;

-- Allow role to build and manage custom schemas (e.g., dbt staging, marts)
GRANT CREATE SCHEMA ON DATABASE ANALYTICS_DB_DEV  TO ROLE TRANSFORMER;
GRANT CREATE SCHEMA ON DATABASE ANALYTICS_DB_TEST TO ROLE TRANSFORMER;
GRANT CREATE SCHEMA ON DATABASE ANALYTICS_DB_PROD TO ROLE TRANSFORMER;

-- -----------------------------------------------------------------------------
-- Step 4: RBAC - Ingestion Role (Azure Data Factory)
-- -----------------------------------------------------------------------------
-- Create role dedicated to raw data ingestion and loading
CREATE ROLE IF NOT EXISTS ADF_LOADER;

-- Grant compute access for loading pipelines
GRANT USAGE ON WAREHOUSE ANALYTICS_WH_DEV  TO ROLE ADF_LOADER;
GRANT USAGE ON WAREHOUSE ANALYTICS_WH_TEST TO ROLE ADF_LOADER;
GRANT USAGE ON WAREHOUSE ANALYTICS_WH_PROD TO ROLE ADF_LOADER;

-- Grant database visibility for target data layers
GRANT USAGE ON DATABASE ANALYTICS_DB_DEV  TO ROLE ADF_LOADER;
GRANT USAGE ON DATABASE ANALYTICS_DB_TEST TO ROLE ADF_LOADER;
GRANT USAGE ON DATABASE ANALYTICS_DB_PROD TO ROLE ADF_LOADER;

-- -----------------------------------------------------------------------------
-- Step 5: User Role Assignment
-- -----------------------------------------------------------------------------
-- Grant transformation role to the active service/developer account
GRANT ROLE TRANSFORMER TO USER SEP30NIT;

```