# ADR-001: Monolithic Rails 8 Architecture (Hotwire)

Status: accepted

Context
-------
The application targets fast iteration and simple local setup for demos and internal use. The team prioritizes developer velocity and low operational overhead for the MVP.

Decision
--------
Adopt a single Rails monolith (Rails 8) with Hotwire (Turbo + Stimulus) for interactive, mostly server-rendered UI. Keep controllers, views, models, and lightweight services in the same repository.

Consequences
------------
- Pros: Simple local development, fast feedback loops, and fewer infrastructure components to manage.
- Pros: Hotwire reduces heavy JavaScript build tooling while enabling dynamic UI behavior.
- Cons: Extracting services or scaling horizontally may require future refactors.

Notes
-----
This ADR reflects the project's emphasis on a Rails+Hotwire monolith for quick demos and maintainable class projects. Consider extracting services only when scaling or multi-team ownership demands it.
