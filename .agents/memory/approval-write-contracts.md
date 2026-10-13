---
name: Approval write contracts
description: Parallel-group policy, domain independence, retry/resubmission evidence and decision-time authorization
---

Generic approval decisions and originating business transitions are separate
responsibilities. Future writers must explicitly decide whether a decision
triggers a domain transition, then coordinate the necessary domain validation,
authoritative history and selected approval/audit evidence transactionally.

**Why:** The user requires approvals to complement, never replace, business
state/history. Approving a workflow alone must not silently pay a receipt,
approve a scope or increase execution funding.

**How to apply:** Serialize outcome writes against the request and affected
domain records consistently, make retries idempotent, and preserve earlier
decision evidence during return/resubmission/reassignment. Define expiry
evidence deliberately rather than treating expiration as rejection.

An approval order identifies a group of targets, not necessarily one person.
Do not infer an all/any rule, independent decision makers, manager identity,
delegation or self-approval policy from the existence of assignment rows.

**Why:** The user's specification requires both sequential and parallel
approvals, while explicitly leaving aggregation and manager resolution to
application logic. A role target and a user target may resolve to the same person.

**How to apply:** Before creating decision services, establish the supported
request-type policies and authorize each actual actor at decision time. Resolve
active role/membership/permission and department/manager eligibility separately
from assignment existence. Reauthorize source-derived content when reading;
later membership changes are not grounds to rewrite earlier immutable evidence.
