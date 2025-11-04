# ADR-004: Deployment — Heroku (current) and Docker (optional)

Status: accepted (Heroku primary)

Context
-------
The application was developed and deployed using Heroku in course/demo contexts. The codebase includes `kamal` and other deployment helpers that could enable containerized or more advanced deployment workflows, but the active deployment path used by the team has been Heroku.

Decision
--------
Treat Heroku as the primary deployment platform for this project. Docker/containerized deployment is considered optional and not currently used in the project's delivery pipeline.

Consequences
------------
- Pros: Simple deployment path (Heroku) and lower operational overhead for course/demo deployments.
- Cons: Less parity if production environments require containers; if you later adopt Docker you should add container images and CI/CD to exercise them.

Notes
-----
- The repository includes `kamal` which can support containerized deployments; consider adding Docker/CICD support later if required.
- The `config/database.yml` currently uses SQLite for local development; for Heroku deploys ensure you enable a Postgres addon and update `config/database.yml` for production or set `DATABASE_URL` appropriately.
