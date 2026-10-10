---
name: Budget ledger contracts
description: Opening funding, internal allocation movements, reversal classification, and future financial writer rules
---

Configured budget is an opening definition, not a cached current balance.
Its matching initial ledger entry must not be added to the definition again
when computing funded state.

**Why:** The requested opening amount and initial funding event represent the
same money. Summing both doubles available funding.

**How to apply:** Future services must serialize initialization, record a single
matching initial event, and derive subsequent financial state from the ledger.
An uninitialized ledger is not an authoritative zero balance. Zero definitions
are permitted during planning, but the current initial-event convention is
positive; explicitly review zero-funded activation before supporting it.

Internal allocation movements redistribute funding rather than increase
project-wide funds. Reversal classification depends on the original event's
effect, not merely the reversal's positive/negative sign.

**Why:** Adding internal distribution to funding inflates balances. A positive
reversal may undo either an expense or a funding reduction, with different
reporting consequences.

**How to apply:** Exclude internal allocation movements from project-funding
totals, define allocation reconciliation/overlap policy, and validate reversal
provenance against the same budget before authoritative reporting. Do not infer
strong linkage from the optional reference string.

Financial ledger append-only behavior and initialization idempotency are
future service contracts, not database guarantees in this foundation.

**Why:** The user requested database structures without financial workflow
triggers. Restrictive FKs preserve attribution but do not prevent direct SQL
edits to a ledger row.

**How to apply:** Future writers must append corrective/reversal events, set
actor attribution from the authenticated employee, and protect initialization
and retries against duplication. Never imply these protections already exist.
