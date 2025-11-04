# ADR-010: Frontend Implementation — ERB + Turbo + Stimulus (Hotwire)

Status: accepted

Context
-------
The UI should be responsive and interactive without requiring heavy JavaScript build tooling for a class project.

Decision
--------
Use ERB for server-rendered views, Turbo for partial updates/streams, and Stimulus for small JS controllers (Hotwire approach). Keep the frontend accessible and keyboard-friendly.

Consequences
------------
- Pros: Simple developer experience, fast iteration, and fewer build tool requirements.
- Pros: Works well with server-side rendering and reduces JS complexity.
- Cons: Not ideal for very large SPA experiences; migrating is possible if needed.

Notes
-----
Prioritize accessible markup and progressive enhancement; limit client-side dependencies to keep the app robust and easier to maintain.
