/* =============================================================================
   Burndown app | 00_setup/03_git_integration.sql
   Purpose : Connect Snowflake to the GitHub repo so SQL and Streamlit deploy from it.
   Repo    : https://github.com/pavelhanys/Project-portfolio-report (public)
   Run as  : ACCOUNTADMIN, then BURNDOWN_ADMIN (switches automatically).
   Needs   : 02_database_schemas.sql
   Re-run  : Safe.

   Public repo, so no Git credentials are needed. If the repo is ever made
   private, see the note at the end of this file.
   ============================================================================= */

-- -----------------------------------------------------------------------------
-- 1. API integration (account-level object, needs ACCOUNTADMIN)
-- -----------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

CREATE API INTEGRATION IF NOT EXISTS BURNDOWN_GIT_API_INTEGRATION
  API_PROVIDER         = GIT_HTTPS_API
  API_ALLOWED_PREFIXES = ('https://github.com/pavelhanys/')
  ENABLED              = TRUE
  COMMENT              = 'Burndown app: access to GitHub repo';

GRANT USAGE ON INTEGRATION BURNDOWN_GIT_API_INTEGRATION TO ROLE BURNDOWN_ADMIN;

-- -----------------------------------------------------------------------------
-- 2. Git repository clone inside Snowflake
-- -----------------------------------------------------------------------------
USE ROLE BURNDOWN_ADMIN;
USE WAREHOUSE BURNDOWN_WH;

CREATE GIT REPOSITORY IF NOT EXISTS BURNDOWN_DEMO.DEPLOY.BURNDOWN_REPO
  API_INTEGRATION = BURNDOWN_GIT_API_INTEGRATION
  ORIGIN          = 'https://github.com/pavelhanys/Project-portfolio-report.git'
  COMMENT         = 'Burndown app source: SQL and Streamlit';

-- Pull the latest commits (run this after every push/merge to main)
ALTER GIT REPOSITORY BURNDOWN_DEMO.DEPLOY.BURNDOWN_REPO FETCH;

-- -----------------------------------------------------------------------------
-- 3. Verify
-- -----------------------------------------------------------------------------
SHOW GIT BRANCHES IN BURNDOWN_DEMO.DEPLOY.BURNDOWN_REPO;
LS @BURNDOWN_DEMO.DEPLOY.BURNDOWN_REPO/branches/main/;

/* -----------------------------------------------------------------------------
   IF THE REPO BECOMES PRIVATE
   1. As BURNDOWN_ADMIN, create a secret with a read-only fine-grained token
      (paste the token only in the worksheet, never commit it):
        CREATE SECRET BURNDOWN_DEMO.DEPLOY.GITHUB_PAT
          TYPE = PASSWORD USERNAME = 'pavelhanys' PASSWORD = '<token>';
   2. As ACCOUNTADMIN:
        ALTER API INTEGRATION BURNDOWN_GIT_API_INTEGRATION
          SET ALLOWED_AUTHENTICATION_SECRETS = (BURNDOWN_DEMO.DEPLOY.GITHUB_PAT);
   3. As BURNDOWN_ADMIN:
        ALTER GIT REPOSITORY BURNDOWN_DEMO.DEPLOY.BURNDOWN_REPO
          SET GIT_CREDENTIALS = BURNDOWN_DEMO.DEPLOY.GITHUB_PAT;
   ----------------------------------------------------------------------------- */
