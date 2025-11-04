# ADR-006: Attachments & ActiveStorage

Status: accepted

Context
-------
Tickets and comments may include file attachments (screenshots, logs). The application should support simple local uploads in development and cloud-backed storage in production.

Decision
--------
Use Rails ActiveStorage for attachments. Configure local disk service for development and a cloud provider (S3-compatible) for production. Keep attachment handling simple (size limits, content-type validation) to reduce abuse.

Consequences
------------
- Pros: Direct integration with Rails, support for variants and direct uploads.
- Pros: Switching storage backends (local ↔ cloud) is straightforward via `config/storage.yml`.
- Cons: Cloud storage introduces credentials and cost; document required env vars and IAM/policy expectations.

Notes
-----
Ensure ActiveStorage migrations are applied and `config/storage.yml` includes both `local` and `amazon` (or S3-compatible) services. Use signed URLs for secure access where appropriate.
