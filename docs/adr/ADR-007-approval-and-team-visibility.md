# ADR-007: Approval workflow, Team-based Visibility & Assignment Strategy

Status: accepted

Context
-------
The application needs an approval flow for tickets, team-based visibility, and a flexible assignment strategy to route work among agents.

Decision
--------
- Model approval fields on `Ticket` (e.g., `approval_status`, `approved_at`, `approver_id`).
- Use `Team` and `TeamMembership` models to scope ticket visibility and assignment.
- Implement assignment modes: manual assignment (via UI) and round-robin assignment. Store assignment strategy and rotation state in a `Setting` model.

Consequences
------------
- Pros: Explicit approval fields enable auditability and clear state transitions.
- Pros: Team membership centralizes access control and assignment scope.
- Pros: Round-robin provides fair automatic distribution; manual assignment allows overrides.
- Cons: Round-robin requires persisting rotation state and rules for skipping inactive agents; edge cases must be tested.

Notes
-----
Implement Pundit policies to enforce who can approve and assign tickets. Keep assignment synchronous for the MVP; move to background jobs only if assignment logic becomes expensive or distributed.
