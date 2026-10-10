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
