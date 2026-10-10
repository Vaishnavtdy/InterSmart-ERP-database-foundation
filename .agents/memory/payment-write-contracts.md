---
name: Payment write contracts
description: Atomic financial state/history changes and service-side consistency boundaries
---

Future payment writers must update current status and append its attributed
history in one transaction. When maintaining a request's paid/partial state,
coordinate that state with receipt confirmation, reversal, or cancellation.

**Why:** History cannot be edited after insertion. A receipt reversal changes
the confirmed-payment total, so updating only the receipt can leave its request
incorrectly marked paid even when the financial totals no longer support that.
The database foundation does not automatically write history or reconcile
request states.

**How to apply:** Serialize financial changes for the affected request, validate
transition and actor permissions, write the payment/request event and state
together, and define deterministic ordering for tied history timestamps.
Do not mistake the current status field for proof of a recorded audit event.

Project/customer/request ownership and matching currency are explicit future
service guarantees, not guarantees from the independent database references.

**Why:** Each referenced entity can exist independently while still belonging
to the wrong customer, project, or currency. Such records would corrupt receipt
reporting despite satisfying every foreign key.

**How to apply:** Validate the complete ownership/currency chain before writing
or aggregating a linked receipt. Preserve historical financial ownership when
considering project/customer reassignment; don't silently migrate old receipts.
