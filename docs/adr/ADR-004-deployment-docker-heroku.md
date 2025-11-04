# ADR-004: Deployment — Kamal + Docker on Heroku

Status: accepted

Context
-------
We want repeatable, consistent deployments for demos and cloud hosting. The repository includes `kamal` which supports containerized deployments and there is value in having parity between local and production environments.

Decision
--------
Adopt Kamal + Docker as the deployment mechanism and target Heroku as the hosting platform for demos and course usage. Provide Dockerfile and Kamal configuration to build and push container images, and ensure Heroku is configured to receive Docker-based deployments.

Consequences
------------
- Pros: Containerization produces reproducible images and helps with parity between dev and prod. Kamal simplifies deploying containers to cloud platforms.
- Cons: Adds build complexity and developer tooling (Docker). Provide clear docs and convenience scripts so students can deploy without deep ops knowledge.

Notes
-----
- Ensure `config/database.yml` and ActiveStorage are configured for production Postgres and cloud storage respectively.
- Provide a simple Heroku deploy guide that uses container images, or allow the existing Heroku git workflow as an alternative for contributors who prefer it.
