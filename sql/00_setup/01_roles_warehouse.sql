/* =============================================================================
   Burndown app | 00_setup/01_roles_warehouse.sql
   Purpose : Create the app roles and the dedicated warehouse.
   Run as  : SECURITYADMIN + SYSADMIN (an ACCOUNTADMIN user has both).
   Re-run  : Safe. Every statement is idempotent.
   ============================================================================= */

-- -----------------------------------------------------------------------------
-- 1. Roles
--    BURNDOWN_ADMIN : owns all objects and the Streamlit app, runs deployments
--    BURNDOWN_USER  : opens the app only (Streamlit runs with owner's rights,
--                     so viewers need no direct access to tables)
-- -----------------------------------------------------------------------------
USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS BURNDOWN_ADMIN
  COMMENT = 'Burndown app: owner of all objects, deploys code';

CREATE ROLE IF NOT EXISTS BURNDOWN_USER
  COMMENT = 'Burndown app: end users of the Streamlit app';

-- Role hierarchy: USER -> ADMIN -> SYSADMIN (so SYSADMIN can still manage everything)
GRANT ROLE BURNDOWN_USER  TO ROLE BURNDOWN_ADMIN;
GRANT ROLE BURNDOWN_ADMIN TO ROLE SYSADMIN;

-- Grant the admin role to whoever runs this script
SET grant_admin_stmt = 'GRANT ROLE BURNDOWN_ADMIN TO USER "' || CURRENT_USER() || '"';
EXECUTE IMMEDIATE $grant_admin_stmt;

-- End users are granted later, e.g.:
-- GRANT ROLE BURNDOWN_USER TO USER "JANE.DOE";

-- -----------------------------------------------------------------------------
-- 2. Warehouse (XSMALL, suspends after 60s idle)
-- -----------------------------------------------------------------------------
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS BURNDOWN_WH
  WAREHOUSE_SIZE      = 'XSMALL'
  AUTO_SUSPEND        = 60
  AUTO_RESUME         = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT             = 'Burndown app: queries, deployments and Streamlit';

GRANT USAGE, OPERATE, MONITOR ON WAREHOUSE BURNDOWN_WH TO ROLE BURNDOWN_ADMIN;
GRANT USAGE                   ON WAREHOUSE BURNDOWN_WH TO ROLE BURNDOWN_USER;

-- -----------------------------------------------------------------------------
-- 3. OPTIONAL cost guardrail (needs ACCOUNTADMIN). Uncomment to enable.
-- -----------------------------------------------------------------------------
-- USE ROLE ACCOUNTADMIN;
-- CREATE RESOURCE MONITOR IF NOT EXISTS BURNDOWN_RM
--   WITH CREDIT_QUOTA = 10
--   FREQUENCY = MONTHLY
--   START_TIMESTAMP = IMMEDIATELY
--   TRIGGERS ON 80  PERCENT DO NOTIFY
--            ON 100 PERCENT DO SUSPEND;
-- ALTER WAREHOUSE BURNDOWN_WH SET RESOURCE_MONITOR = BURNDOWN_RM;

-- -----------------------------------------------------------------------------
-- 4. Verify
-- -----------------------------------------------------------------------------
SHOW ROLES LIKE 'BURNDOWN%';
SHOW WAREHOUSES LIKE 'BURNDOWN_WH';
SHOW GRANTS TO ROLE BURNDOWN_ADMIN;
