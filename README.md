# Ticketing System

## Lo-Fi Architecture

Ticketing System is a monolithic Rails application that handles ticket creation, assignment, commenting, approval flows, team-based visibility, and user management. The diagram below is a simple lo-fi view of how requests flow through the app.

```text
+----------------------+     +----------------------------+     +--------------------+
|  Web Browser / UI    | <-> | Rails Controllers & Views  | <-> |  Frontend Assets   |
|  (ERB, CSS, JS,      |     |  (Tickets, Users, Teams)   |     |  (Turbo/Stimulus)  |
|   Turbo/Stimulus)    |     |                            |     |                    |
+----------------------+     +-----------+----------------+     +--------------------+
            |                         |
            | HTTP / Turbo Streams    |  reads / writes
            v                         v
     +----------------------+     +----------------------+
     |  Client-side JS /    | --> |  Rails Controllers   |
     |  Turbo Frames        |     |  (TicketsController, | 
     |                      |     |   UsersController,   |
     +----------------------+     |   TeamsController,   |
                                  |   SessionsController) |
                                  +-----------+-----------+
                                              |
                                              v
```

## Architecture

The architecture diagram (rendered image) shows the major pieces and how requests flow through the system. See `docs/project2architecture_diagram.png` in the `docs/` folder.

![Architecture diagram](docs/project2architecture_diagram.png)

### Architecture Decision Records (ADRs)

ADRs capture high-level technical decisions. They live in `docs/adr/`.

| ADR # | Title |
|---|---|
| ADR-001 | Monolithic Rails 8 architecture |
| ADR-002 | Authentication with Google OAuth2 (OmniAuth) |
| ADR-003 | Database: SQLite (dev/test) + PostgreSQL (prod) |
| ADR-004 | Deployment: Heroku (primary), Docker optional |
| ADR-005 | Testing: RSpec + Cucumber (tooling present) |
| ADR-006 | Attachments: ActiveStorage |
| ADR-007 | Approval workflow & Team visibility |
| ADR-008 | CI pipeline (proposed / not configured) |
| ADR-009 | Mailers (not implemented) |
| ADR-010 | Frontend: ERB + Turbo + Stimulus |

---

## Class Diagram

Main domain models and relationships are represented in the class diagram (rendered image in `docs/`).

![Class diagram](docs/project2_class_diagram.png)

---

## Components

### Frontend
- Server-rendered views (ERB) with Turbo and Stimulus for interactivity.
- Key pages: Home/Dashboard, Tickets (index/new/edit/show), Users, Teams, Sessions (login).

### Backend
- Controllers: coordinate requests and authorization (Pundit) and render views or JSON.
- Models: `User`, `Ticket`, `Comment`, `Team`, `TeamMembership`, `Setting`.
- Policies: `TicketPolicy`, `TeamPolicy`, `CommentPolicy`, `TeamMembershipPolicy`.

### Database
- Default development/test DB: SQLite3 (configured in `config/database.yml`, DB files under `storage/`).
- Production: PostgreSQL is recommended (Gemfile includes `pg`).

### External integrations
- Google OAuth2 (OmniAuth + omniauth-google-oauth2)
- Dotenv for environment variables
- Pundit for authorization

### Testing & QA
- RSpec for unit/model/policy/request specs
- Cucumber + Capybara for high-level feature tests
- Brakeman and RuboCop are included in the Gemfile for security and linting

---

## User request flow (high level)

User -> Browser -> Rails Router -> Controller -> Pundit authorization -> Model -> Database

Responses are rendered as HTML via ERB or as JSON for API-like endpoints; Turbo Streams and Frames are used for partial page updates.

---

## Tests (quick summary)

Run tests locally:

```bash
# Run full RSpec suite
bundle exec rspec

# Run Cucumber features
bundle exec cucumber --format pretty

# Run a focused file
bundle exec rspec spec/requests/tickets_spec.rb
```

---

## Debug pointers (concise)

- OAuth login failures: check `GOOGLE_OAUTH_CLIENT_ID` and `GOOGLE_OAUTH_CLIENT_SECRET` in `.env` and authorized redirect URIs in Google Console.
- Pundit errors: ensure `include Pundit` in `ApplicationController` and the `pundit` gem is present.
- Asset issues in production: inspect `assets:precompile` logs; reproduce locally with `RAILS_ENV=production bundle exec rails assets:precompile`.
- SQLite vs Postgres differences: prefer testing with Postgres locally for production parity.

---

## Notes & next steps

- Diagrams and ADRs are in `docs/` (please confirm or add additional ADRs).
- Consider adding GitHub Actions workflows to run tests and Brakeman on PRs.

---

## From Local Setup to Live Deployment 🚀

This section shows the minimal steps to get the app running locally and an example path to deploy to Heroku.

### 1️⃣ Prerequisites

| Tool | Version in this project | Notes / source |
| :--- | :---: | :--- |
| Ruby | 3.4.5 | `.ruby-version` at repo root indicates Ruby 3.4.5 |
| Bundler | 2.7.1 | `BUNDLED WITH` section in `Gemfile.lock` |
| Rails | 8.0.3 | `Gemfile` / `Gemfile.lock` (rails ~> 8.0.3) |
| SQLite3 (gem) | 2.7.4 | `sqlite3` gem version in `Gemfile.lock` (native SQLite3 system version not specified in repo) |
| PostgreSQL (pg gem) | 1.6.2 | `pg` gem version in `Gemfile.lock`; production DB adapter recommended as Postgres for Heroku deploys |
| Git | not specified in repo | Git client version is not tracked in the repository; use a modern Git (2.x+ recommended) |
| Heroku CLI | not specified in repo | CLI version not tracked; install latest Heroku CLI if deploying to Heroku |

### 2️⃣ Local installation

```bash
git clone <repo-url>
cd Ticketing-System
bundle install
rails db:migrate
rails db:seed # optional
```

Create `.env` with your Google OAuth credentials (used by `dotenv-rails`):

```bash
echo "GOOGLE_OAUTH_CLIENT_ID=your_client_id" >> .env
echo "GOOGLE_OAUTH_CLIENT_SECRET=your_client_secret" >> .env
```

Start the server:

```bash
bin/rails server
# open http://localhost:3000
```

### 3️⃣ Running tests

```bash
bundle exec rspec
bundle exec cucumber
```

### 4️⃣ Deploy (Heroku example)

```bash
heroku login
heroku create your-ticketing-app-name
heroku addons:create heroku-postgresql:hobby-dev --app your-ticketing-app-name
git push heroku documentation_final:main
heroku run rails db:migrate --app your-ticketing-app-name
heroku open --app your-ticketing-app-name
```

Notes:
- Update `config/database.yml` for PostgreSQL in production.
- Store OAuth secrets as environment variables on the platform.

---

If you'd like, I can draft a GitHub Actions workflow that runs RSpec, Cucumber, RuboCop and Brakeman on PRs and stage it for review. I will not commit or push anything unless you ask.
