# ADR-005: Testing Frameworks — RSpec, FactoryBot + Cucumber

Status: accepted (tooling present; CI not configured)

Context
-------
The repository includes RSpec and Cucumber (with Capybara) and related helper gems. Tests are important for correctness, instructor evaluation, and safe refactoring.

Decision
--------
Use RSpec with FactoryBot for unit/model/policy/request specs, and Cucumber + Capybara for high-level acceptance tests. Mock OAuth callbacks in test/CI to avoid external dependencies. Use SimpleCov for coverage reporting locally and in CI.

Consequences
------------
- Pros: Strong test coverage at model and integration levels; deterministic OAuth testing improves CI reliability.
- Cons: Maintaining feature tests can be work-intensive; split long-running tests into scheduled or on-demand CI jobs.

Future
------
When adding CI, run fast RSpec checks on PRs and consider running Cucumber features in a separate workflow (nightly or on-demand) to keep PR feedback fast.
