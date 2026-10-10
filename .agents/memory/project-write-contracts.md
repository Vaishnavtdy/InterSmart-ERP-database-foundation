---
name: Project write contracts
description: Historical staffing context and coordinated lifecycle/scope approval writes for future services
---

Project team department records are historical assignment context, not a
continuously synchronized copy of an employee's current department.

**Why:** An employee transfer must not relabel earlier project participation
or erase which department staffed the assignment.

**How to apply:** When implementing employee transfers or roster editing, retain
the department on historical assignment rows. A new assignment may use the
employee's new department.

Project status changes and attributed history insertion must commit together.
Database-only setup deliberately does not implement an automatic transition
writer.

**Why:** Reasons are read from recorded history, while lifecycle state lives on
the project. Updating only one creates inconsistent state, and append-only
history cannot be repaired by editing past events.

**How to apply:** Future project-writing services must use one transaction for
the status update and its from/to status, reason, actor, and timestamp event.
Define event ordering for tied timestamps before relying on a latest-event
query for the current condition.

Scope approval writers must fully populate a draft before approving it, and
replace an approved revision by superseding the old one and approving the new
one in a single transaction.

**Why:** Approval seals content and its item set permanently; inserting items
after approval fails. A project has at most one approved scope, so separate
commits during replacement can expose a gap or leave incomplete supersession.

**How to apply:** Future services should serialize approval attempts per
project, allocate version numbers with conflict handling, populate draft items,
and commit both approval-state changes together. Corrections to approved scope
content require another version, not edits to the historical snapshot.
