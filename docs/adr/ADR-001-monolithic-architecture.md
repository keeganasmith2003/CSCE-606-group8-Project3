# ADR-001: Monolithic Rails 8 Architecture

Status: accepted

Context
-------
This project is a small-medium sized internal ticketing system developed for a class project. Simplicity and fast feedback loops are important for development and evaluation.

Decision
--------
Adopt a single Rails monolith (Rails 8) containing controllers, views, models, and jobs. Keep frontend as ERB/Turbo/Stimulus inside the same repo.

Consequences
------------
- Pros: Simple local development, fewer moving parts, straightforward deployment to Heroku/containers.
- Cons: Scaling larger components later will require refactoring (extract services or APIs).
