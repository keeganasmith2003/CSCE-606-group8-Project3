# ADR-002: Authentication — Devise + OmniAuth (Google/GitHub)

Status: accepted (tooling present)

Context
-------
Authentication should be simple for users and secure for demos and internal use. The project prefers delegating identity to OAuth providers for reduced password handling and easier onboarding.

Decision
--------
Use Devise for user/session management plus OmniAuth strategies (Google and optionally GitHub) for OAuth login. In development and CI, provide mocked OAuth callbacks to allow deterministic tests.

Consequences
------------
- Pros: Devise provides battle-tested session management, recoverable passwords (if needed), and integrations that make it easier to manage user lifecycle.
- Pros: OmniAuth (Google/GitHub) simplifies onboarding and reduces password surface area.
- Cons: Adds Devise configuration and migrations; OAuth providers require client credentials and redirect setup.

Notes
-----
If Devise is not already present in the codebase, adding it should be done carefully to avoid conflicting user models; alternatively, a lightweight custom authentication plus OmniAuth may be used. For CI, mock OAuth flows to avoid flaky external calls.
