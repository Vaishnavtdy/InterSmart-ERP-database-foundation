---
name: Task write contracts
description: Atomic task assignment/history writes and intentional graph-validation boundaries
---

Future reassignment must lock the task, close its old assignment period,
append the new period, and change the current assignee atomically. Include
status and attributed status history when the operation changes lifecycle state.
Unassignment closes the old period without inventing a replacement employee.

**Why:** Current assignment and assignment history are independent structures.
Active-period uniqueness prevents two open periods but does not synchronize
them with current state. History facts cannot be relabeled, and inserting a new
active period before releasing the old one conflicts with the chosen contract.

**How to apply:** Use one serialized transaction per affected task; capture
change times after obtaining the lock and define history ordering when timestamps
tie. Do not infer the current assignee from an arbitrarily ordered historical
query or claim database defaults automatically create the assignment event.

Graph validation beyond direct self-links remains a service responsibility.
Cross-project dependency links are not categorically prohibited.

**Why:** Same-project hierarchy is intentional, but dependencies can represent
coordination across projects. The foundation does not decide cross-project
authorization, longer cycles, scheduling, or symmetric related-link policy.

**How to apply:** Explicitly authorize graph edits, detect longer parent and
blocking cycles before committing, and specify allowed cross-project links.
Treat related links as directed stored associations unless a future policy
normalizes them; don't introduce recursive triggers or a scheduler implicitly.

UI/UX/Development task links require same-project ownership and the matching workstream, but those
cross-table classification rules are a future service contract, not an FK
guarantee. Validate subsequent ownership/workstream edits as well as link creation.

**Why:** The common task engine remains domain-neutral; domain links enforce valid
entities and UI section/page, UX context/version or Development module/version
containment without implementing lifecycle workflows.
A link validated once can become invalid when either endpoint is later moved.

**How to apply:** Check existing domain associations before changing task project or
workstream, or moving version definitions/deliverables. Serialize competing ownership
edits and link writes; do not assume a retained FK proves classification alignment.

UX flow-step screen references require same-version alignment in future services.

**Why:** Steps intentionally retain the requested field shape rather than carrying
redundant version identity or adding validation triggers. Their screen FK proves
existence, not alignment with the owning flow's version.

**How to apply:** Validate both endpoints when creating/editing steps and before
moving a screen or flow between versions. Permit NULL screens while planning.

Sprint/task workstream alignment and permitted membership changes remain
future service rules. Sprint completion does not imply task completion.

**Why:** Sprints are generic project/workstream planning records, independent
of department version definitions and execution lifecycle. The database
enforces project containment but deliberately does not orchestrate task state,
active-sprint policy or immutable membership history.

**How to apply:** Authorize and serialize membership edits, validate workstream
and any department-version associations, and decide whether membership history
is needed before changing completed-sprint policy. Do not silently complete
tasks or rewrite their task-status/assignment history when a sprint closes.
