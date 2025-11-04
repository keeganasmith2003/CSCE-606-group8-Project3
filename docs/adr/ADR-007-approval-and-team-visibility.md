# ADR-007: Approval workflow and Team-based Visibility

Status: accepted

Context
-------
The app supports workflows where staff may approve/reject tickets and teams determine visibility/assignment.

Decision
--------
Model approval fields on the Ticket (approval_status, approved_at, approver) and use Team & TeamMembership models to scope ticket visibility and assignment.

Consequences
------------
- Pros: Simple, explicit fields make approval timelines auditable. Team membership centralizes access control.
- Cons: Complex sharing rules may need policy tuning; use Pundit policies to enforce rules.
