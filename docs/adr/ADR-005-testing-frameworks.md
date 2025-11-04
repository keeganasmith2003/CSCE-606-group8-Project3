# ADR-005: Testing Frameworks — RSpec + Cucumber

Status: accepted (tooling present; CI not configured)

Context
-------
The repository includes RSpec and Cucumber (with Capybara) and related helper gems. These frameworks are used for local testing and instructor evaluation.

Decision
--------
Keep RSpec for model/request/policy specs and Cucumber for high-level acceptance tests. SimpleCov is included for coverage reporting locally. Note: the project does not currently run these suites automatically on pull requests — there is no CI workflow configured in the repo to execute RSpec/Cucumber on PRs.

Consequences
------------
- Pros: The project has a comprehensive local test setup; instructors and contributors can run focused or full test suites locally.
- Cons: No automated verification on PRs; adding CI (GitHub Actions) remains a recommended follow-up to enforce checks on merges.

Future
------
When adding CI, prefer running RSpec in PRs and schedule Cucumber feature runs (or run them as on-demand jobs) to avoid long PR feedback loops.
