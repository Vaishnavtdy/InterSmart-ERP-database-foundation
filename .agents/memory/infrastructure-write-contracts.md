---
name: Infrastructure write contracts
description: Project containment across deployment metadata and serialized go-live readiness decisions
---

Future writers must validate that deployment, hosting server and go-live
attempt belong to the same Project, including later ownership edits.

**Why:** Optional cross-module references intentionally preserve the existing
Development deployment record instead of copying project identity/history into
an infrastructure deployment engine. Existence and local version containment
do not establish agreement across Development and Infrastructure.

**How to apply:** Check both ownership paths on association creation and before
moving a server, Development version or Infrastructure version. Serialize
association/ownership edits so a concurrent move cannot invalidate a checked link.

Go-live readiness and completion gates require serialized parent/checklist
writes; configuration flags are reports, not evidence that services were run.

**Why:** The foundation models attempts/checklists/handovers without orchestrating
release, monitoring, backups or CI/CD. A readiness decision can become stale
when another writer changes a required checklist item or its applicability.

**How to apply:** Define required-item, approval and QA readiness policy in the
future service, authorize overrides, and lock the attempt consistently with
checklist edits. Never infer that a stored URL or configured flag proves a live
service exists, or rewrite old attempt/deployment provenance to represent a retry.
