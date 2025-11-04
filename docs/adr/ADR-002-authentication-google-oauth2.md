# ADR-002: Authentication with Google OAuth2 (OmniAuth)

Status: accepted

Context
-------
The app needs simple and secure user authentication. Managing passwords for users adds development and security overhead.

Decision
--------
Use OmniAuth with the `omniauth-google-oauth2` strategy to authenticate users via Google accounts. New users are created on first login using data from the provider.

Consequences
------------
- Pros: Delegates authentication to Google (less password management), simpler dev experience for course demos.
- Cons: Requires configuring OAuth credentials; users must have Google accounts. Consider fallback for non-Google users if required.
