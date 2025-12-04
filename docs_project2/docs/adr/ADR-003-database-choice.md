# ADR-003: Database choice — PostgreSQL (production) + SQLite (dev/test)

Status: accepted

Context
-------
Local development should be easy for contributors; production should be reliable and compatible with cloud providers (Heroku). Attachments require file storage (ActiveStorage) and production-grade storage.

Decision
--------
Use PostgreSQL for production deployments and SQLite for easy local development/test. Use ActiveStorage for attachments with a cloud-backed service (S3) for production and local disk in development.

Consequences
------------
- Pros: PostgreSQL provides reliability, better concurrency, and features for production workloads.
- Pros: ActiveStorage integrates with Rails and supports multiple services.
- Cons: Slightly more setup for local development if developers want production parity; recommend scripts or docs to help spin up Postgres locally.

Notes
-----
The Gemfile already includes `pg` and ActiveStorage scaffolding; ensure production `DATABASE_URL` is set (Heroku) and configure ActiveStorage service in `config/storage.yml` for production.
