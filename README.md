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

![Architecture diagram](/home/mihir/Downloads/Gemini_Generated_Image_otit34otit34otit.png)

### Architecture Decision Records (ADRs)

ADRs capture high-level technical decisions. They live in `docs/adr/`.

| ADR # | Title |
|---|---|
| ADR-001 | Monolithic Rails 8 architecture (Hotwire) |
| ADR-002 | Authentication: Devise + OmniAuth (Google/GitHub) |
| ADR-003 | Database: PostgreSQL (prod), SQLite for local dev; ActiveStorage for attachments |
| ADR-004 | Deployment: Kamal + Docker on Heroku |
| ADR-005 | Testing: RSpec, FactoryBot, Cucumber |
| ADR-006 | Attachments: ActiveStorage |
| ADR-007 | Assignment workflow: Manual + Round-Robin |
| ADR-008 | CI pipeline (proposed / not configured) |
| ADR-009 | Mailers (not implemented) |
| ADR-010 | Frontend: ERB + Turbo + Stimulus (Hotwire) |

---

## Class Diagram

Main domain models and relationships are represented in the class diagram (rendered image in `docs/`).

![Class diagram](docs/project2_class_diagram.png)

---

## System architecture

Key points:
- Google/GitHub OAuth login (OmniAuth) for quick access
- Ticket CRUD with status and priority enums
- Manual and round-robin ticket assignment modes
- Public vs internal comments for collaboration
- Minimal but functional roles: requester, agent, admin

- Monolithic Rails 8 MVC with Hotwire (Turbo + Stimulus)
- PostgreSQL (production) and ActiveStorage for attachments
- Devise + OmniAuth for authentication
- Pundit for authorization and role management
- Deployed via Kamal + Docker on Heroku

## Data model overview

- Core relationships: User ↔ Ticket ↔ Comment
- Teams & TeamMemberships organize agents and scoping
- `Setting` model stores assignment strategy (manual vs round-robin) and feature toggles
- Enum fields for role, ticket status, and comment visibility ensure consistency
- Proper database indexes are recommended on foreign keys and enum fields for fast lookups and integrity

## Assignment workflow

- Manual assignment: Admins and Agents can assign tickets from the UI dropdown
- Auto round-robin: toggled in `Settings` and enabled for fair rotation among active agents
- Rotation state is persisted (e.g., keep last-assigned index) to ensure balanced distribution and traceability
- For MVP this is implemented synchronously — no background jobs required

## Security & access control

- Devise + OmniAuth handle authentication (with mocked callbacks for CI)
- Pundit policies define per-role permissions (requester/agent/admin)
- CSRF protection enabled by Rails; OAuth logs should be filtered for secrets
- Internal comments are restricted to agents and admins via Pundit
- Strict input validations and DB constraints enforce data integrity

## UI / UX

- Server-rendered responsive layout with clear navigation and role-aware navbar
- Single ticket page combines status, comments, attachments, and assignment controls
- Focus on accessibility and lightweight JS—app remains usable with minimal JS

## Testing & deployment

- RSpec + FactoryBot for unit and policy tests
- Cucumber (with Capybara) for end-to-end acceptance tests
- OAuth callbacks are mocked in CI to improve reliability
- Deploy via Kamal + Docker to Heroku; dotenv used for secrets management and SSL is enforced where possible

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
