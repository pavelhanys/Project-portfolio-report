/* =============================================================================
   Burndown app | 00_setup/02_database_schemas.sql
   Purpose : Create the database and the layer schemas, owned by BURNDOWN_ADMIN.
   Run as  : SYSADMIN, then BURNDOWN_ADMIN (switches automatically).
   Needs   : 01_roles_warehouse.sql
   Re-run  : Safe. Uses IF NOT EXISTS, never drops or replaces.
   ============================================================================= */

-- -----------------------------------------------------------------------------
-- 1. Database: created by SYSADMIN, ownership handed to BURNDOWN_ADMIN
-- -----------------------------------------------------------------------------
USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS BURNDOWN_DEMO
  COMMENT = 'Burndown app: source, silver, status updates and app layer';

GRANT OWNERSHIP ON DATABASE BURNDOWN_DEMO TO ROLE BURNDOWN_ADMIN COPY CURRENT GRANTS;

-- -----------------------------------------------------------------------------
-- 2. Schemas: created and owned by BURNDOWN_ADMIN
-- -----------------------------------------------------------------------------
USE ROLE BURNDOWN_ADMIN;
USE WAREHOUSE BURNDOWN_WH;
USE DATABASE BURNDOWN_DEMO;

CREATE SCHEMA IF NOT EXISTS BRONZE
  COMMENT = 'Source tables (dummy data in DEMO)';

CREATE SCHEMA IF NOT EXISTS SILVER
  COMMENT = 'BURNDOWN_SILVER view, structure fixed by agreed metadata';

CREATE SCHEMA IF NOT EXISTS UPDATES
  COMMENT = 'Write-back from Streamlit: RAG, executive message, RAID, milestones. Append-only, never replaced by deployments';

CREATE SCHEMA IF NOT EXISTS APP
  COMMENT = 'Reporting views read by Streamlit, and the Streamlit object';

CREATE SCHEMA IF NOT EXISTS DEPLOY
  COMMENT = 'Git repository clone and Git credentials. No end-user access';

-- Extra protection for collected updates: longer Time Travel.
-- Values above 1 day need Enterprise edition or higher. Uncomment if available.
-- ALTER SCHEMA UPDATES SET DATA_RETENTION_TIME_IN_DAYS = 30;

DROP SCHEMA IF EXISTS PUBLIC;

-- -----------------------------------------------------------------------------
-- 3. End-user access: just enough to open the app
--    (USAGE on the Streamlit object itself is granted when the app is created)
-- -----------------------------------------------------------------------------
GRANT USAGE ON DATABASE BURNDOWN_DEMO TO ROLE BURNDOWN_USER;
GRANT USAGE ON SCHEMA   BURNDOWN_DEMO.APP TO ROLE BURNDOWN_USER;

-- -----------------------------------------------------------------------------
-- 4. Verify
-- -----------------------------------------------------------------------------
SHOW SCHEMAS IN DATABASE BURNDOWN_DEMO;
SHOW GRANTS ON DATABASE BURNDOWN_DEMO;
SHOW GRANTS TO ROLE BURNDOWN_USER;
