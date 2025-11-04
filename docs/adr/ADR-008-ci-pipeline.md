# ADR-008: Continuous Integration Pipeline

Status: proposed (not configured)

Context
-------
The repository includes RSpec, Cucumber, RuboCop, and Brakeman as development/test dependencies. Automated checks on pull requests would improve quality and guardrails.

Decision
--------
Do not configure a CI pipeline in the repository at this time. While a GitHub Actions workflow is recommended, the current project does not have a CI workflow that runs RSpec/Cucumber/RuboCop/Brakeman on pull requests.

Consequences
------------
- Pros: Reduces onboarding/setup for instructors/students who may be running tests locally. Avoids long CI runs for feature-heavy suites until tests are optimized.
- Cons: Pull requests do not have automated test/scan feedback. Merges rely on manual verification by contributors.

Future
------
When ready, add a GitHub Actions workflow that:

- Runs fast checks (Rubocop, Brakeman) on every PR.
- Runs RSpec (unit/request/policy specs) on PRs.
- Optionally runs Cucumber feature tests in a separate, on-demand job or a nightly job to avoid long PR wait times.

The repo already contains the tooling; this ADR records that CI is desired but currently not applied to PRs.
