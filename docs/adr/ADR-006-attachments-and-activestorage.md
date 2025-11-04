# ADR-006: Attachments & ActiveStorage

Status: accepted

Context
-------
Tickets need file attachments for screenshots or logs. Rails provides ActiveStorage to manage blobs and files.

Decision
--------
Use ActiveStorage for handling attachments (local disk in dev, cloud-backed storage like S3 in production if enabled).

Consequences
------------
- Pros: Built-in Rails approach, supports variants and direct uploads.
- Cons: Requires storage service configuration for production; migration to S3 recommended for multi-replica production environments.
