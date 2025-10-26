# CSCE-606-group6-Project2

## Overview

**CSCE-606-group6-Project2** is a Role-Based Ticket Management System built with Ruby on Rails. It enables authenticated users to create, assign, edit, and comment on support tickets, with role-based visibility and administrative controls.

## Key Layers

- **Presentation Layer (Views & Routes)**
  - Provides the UI for users to view, create, edit and manage tickets and comments.
  - Interacts with controllers to trigger application logic and render pages.

- **Controller Layer**
  - Handles incoming HTTP requests, applies Pundit authorization policies, and interacts with models.
  - Notable controllers:
    - TicketsController — ticket lifecycle (create, edit, assign, destroy)
    - CommentsController — threaded discussion on tickets
    - UsersController — sysadmin user management
    - SessionsController — OAuth2-based authentication (OmniAuth)

- **Model Layer (ActiveRecord)**
  - Encapsulates business logic and relationships:
    - **User** — authenticated via Google OAuth2 (OmniAuth); roles: user, staff, sysadmin
    - **Ticket** — core entity with enums for status, priority, and category
    - **Comment** — threaded messages, with visibility controls
    - **Setting** — key-value store for dynamic config (e.g., round-robin index)

- **Authorization & Authentication**
  - **Authentication:** Google OAuth2 via `omniauth-google-oauth2`.
  - **Authorization:** Pundit policies enforce role-based permissions on resources.

- **Database Layer**
  - Persistent storage for users, tickets, comments and settings.
  - Foreign key constraints help ensure data integrity (tickets must have a requester).

## Highlights

- **Round-Robin Auto Assignment** — optional automatic assignment of new tickets to staff agents using `Setting` to track rotation.

- **Role-Based Access Control**
  - **Requester (user):** create and view own tickets, add public comments
  - **Staff (agent):** view assigned tickets, add internal comments, assign tickets
  - **Sysadmin:** manage users, settings, and global data

- **Extensibility** — designed to be extended with new categories, notifications, analytics, etc.

## Architecture Diagrams

Below are the architecture and class diagrams. The feature renderer used for tests may display local images; if you don't see the images, copy them into the repository (for example `doc/images/`) and update the paths accordingly.

**Architecture Diagram**

![Project Architecture](doc/images/project2architecture_diagram.png)

**Class Diagram**

![Class Diagram](doc/images/project2_class_diagram.png)

## How to run (notes)

- Ruby version: specify in `.ruby-version` or Gemfile
- System dependencies: database (SQLite/Postgres), Redis (optional for jobs), etc.
- Configuration: set `config/credentials` and OAuth client IDs/secrets for Google
- Database setup:
  - `bundle install`
  - `rails db:create db:migrate db:seed`

- Running tests:
  - Unit / RSpec: `bundle exec rspec`
  - Cucumber features: `bundle exec cucumber features/<feature>.feature`

## Common development tips

- The test Cucumber setup in `features/support` uses an OmniAuth test helper that logs in a test user (see `features/support/login_helper.rb`). Many feature definitions assume the test user email `testuser@example.com` — if you add features that interact with authentication, either use the project's login helper or seed matching users in the feature tables.

## TODO / Checklist (suggested)

- Add detailed environment and dependency instructions
- Add deployment instructions and example container/Docker setup
- Add docs images to `doc/images/` to make the README portable

---
