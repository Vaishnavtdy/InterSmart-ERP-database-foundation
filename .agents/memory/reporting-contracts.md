---
name: Reporting architecture contracts
description: Metadata-only reporting, future calculation authorization and target policy boundaries
---

Dashboard measurements must always derive from transactional records; targets
are authored goals, not actual results. JSON configurations are metadata only.

**Why:** The user explicitly requires no dashboard/KPI result persistence,
duplicate business facts, project progress counters or financial summary fields.
Reports prepare configuration now; they do not implement query execution.

**How to apply:** Future services resolve registered calculation/query keys,
validate metadata schemas and apply source authorization before aggregating,
not after results have already exposed financial/HR information. Saved filters,
scope labels, assignments and system flags never grant permission. SQL JSON
object-shape checks are not semantic or authorization validators.

Target overlap/resolution and scope-specific default-view selection remain
business policy decisions, not silently inferred behavior.

**Why:** No precedence or overlapping-period rule was specified, and generic
employee/department applicability must not create ambiguous dual subjects.
One default globally would improperly conflate distinct dashboard/report scopes.

**How to apply:** Define an explicit as-of target resolution policy before using
baseline, period or subject goals. Retain the difference between applicability,
author and numeric override; do not manufacture actuals from targets or assume
NULL means zero. Decide default selection scope and serialize changes when UX
is implemented. Preserve existing financial ledger/payment writer contracts
and historical assignment grain in calculations instead of naive join-and-sum.
