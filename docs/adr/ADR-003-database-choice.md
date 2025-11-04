# ADR-003: Database choice — SQLite (dev/test) and PostgreSQL (production)

Status: accepted

Context
-------
Development should be easy to set up for students and CI. Production should be reliable and compatible with cloud providers.

Decision
--------
Use SQLite for local development and test by default (fast, zero-config). Support PostgreSQL for production deployments (Gemfile includes `pg`).

Consequences
------------
- Pros: Easy local setup for developers; production-grade DB available for deployments.
- Cons: SQL dialect differences; recommend running a local Postgres environment when preparing production deployments.
