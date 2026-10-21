# Burndown app (Streamlit in Snowflake)

Project burndown dashboard with write-back of status updates (RAG, executive message, RAID, milestones).

## Structure

| Folder | Contents | How it runs |
|---|---|---|
| `sql/00_setup/` | Roles, warehouse, database, schemas, Git integration | Once, by hand in a Snowsight worksheet, in file order |
| `sql/10_bronze/` | Source tables | `EXECUTE IMMEDIATE FROM` the Git clone |
| `sql/20_silver/` | `BURNDOWN_SILVER` view (structure fixed by agreed metadata) | As above |
| `sql/30_updates/` | Write-back tables (append-only) and migrations | As above. Never `CREATE OR REPLACE` |
| `sql/40_app/` | Reporting views for Streamlit | As above |
| `sql/90_seed/` | Dummy data | DEV/DEMO only, run once |
| `streamlit/` | Streamlit in Snowflake app | Created from the Git clone |

## Rules

- No credentials in this repo. The repo is public: commit only dummy data and nothing client-identifying.
- Scripts must be safe to re-run.
- After merging to `main`: `ALTER GIT REPOSITORY BURNDOWN_DEMO.DEPLOY.BURNDOWN_REPO FETCH;`
