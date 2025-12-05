# ADR-009: Mailers and Notifications

Status: not-implemented

Context
-------
During initial development we considered sending email notifications for ticket updates and approvals. Mailer code (Action Mailer) would be the typical Rails approach.

Decision
--------
Do not implement mailers at this time. There are no mailer classes or mailer-related gems (for example `letter_opener`) in the current codebase. Email delivery may be added later if requirements demand outbound notifications.

Consequences
------------
- Pros: Keeps the current deliverables focused and reduces configuration burden (SMTP credentials, provider setup).
- Cons: Users will not receive email notifications for approvals/updates until mailers are implemented. Adding mailers later will require environment configuration and possibly background delivery.

Notes
-----
This ADR documents the intentional absence of mailers in the current project. If mailers are required later, consider adding `letter_opener` for development and a transactional provider (SendGrid, Mailgun) for production, and include environment variable docs.
