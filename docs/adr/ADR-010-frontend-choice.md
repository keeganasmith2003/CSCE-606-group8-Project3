# ADR-010: Frontend Implementation — ERB + Turbo + Stimulus

Status: accepted

Context
-------
The UI should be responsive and interactive without adding heavy JS build steps for the class project.

Decision
--------
Use ERB for server-rendered views, Turbo for partial updates, and Stimulus for small JS controllers. Leverage importmap-rails so no Webpack/Vite build step is required for basic interactivity.

Consequences
------------
- Pros: Simple developer experience, fast iteration, fewer build tool hassles.
- Cons: Not ideal for very large single-page-app experiences; can be incrementally migrated if necessary.
