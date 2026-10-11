---
name: HR write contracts
description: Atomic leave decision/balance writes and actual HR decision-maker attribution
---

Future leave writers must coordinate request state, attributed history and
affected balance counters in one serialized, idempotent transaction.

**Why:** Leave balances and decisions intentionally remain separate records,
without automatic reservations, accrual, reversals or working-day calculation.
A retry or cancellation can otherwise double-reserve or refund days, and a
cross-year request may touch more than one annual bucket.

**How to apply:** Define used/pending semantics, calendars, timezone and cross-year
policy before implementing writers. Lock the request and affected balance
buckets consistently, compute transition effects once and retain earlier
decision evidence instead of rewriting approval as cancellation.

Actual HR decision makers and reviewers must not be inferred from line-manager
relationships or common task assignment.

**Why:** The user explicitly requires that the employee's manager is not always
the approver. Task ownership is operational responsibility, not proof of authority
over leave, review or confidential complaint decisions.

**How to apply:** Validate the authorized actor for each HR operation, record that
actual person and timestamp, and separately validate history authorship. Common
Task/File metadata and downloads need the linked HR record's access policy;
linking a sensitive record does not itself protect copied titles/comments.
