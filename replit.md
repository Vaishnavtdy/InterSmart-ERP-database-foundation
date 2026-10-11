# InterSmart ERP

An internal ERP for InterSmart Technologies, built incrementally around a
single-organization PostgreSQL database.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — run the API server (port 5000)
- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from the OpenAPI spec
- `pnpm --filter @workspace/database run db:validate` — validate the Prisma schema
- `pnpm --filter @workspace/database run db:generate` — generate the Prisma client
- `pnpm --filter @workspace/database run db:migrate:dev --name <change-name> --create-only` — create a development migration for SQL review
- `pnpm --filter @workspace/database run db:migrate:deploy` — apply committed migrations
- `pnpm --filter @workspace/database run db:seed` — seed the nine departments without creating accounts
- Required env: `DATABASE_URL` — Postgres connection string

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- API: Express 5
- Planned ERP database: PostgreSQL + Prisma ORM (`packages/database`)
- Existing API scaffold: Express 5; NestJS/Next.js application work is not part of the database foundation
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)

## Where things live

- `packages/database/prisma/schema.prisma` — ERP database schema
- `packages/database/prisma/migrations/` — reviewed Prisma migrations
- `docs/database/` — database usage, ERD, and design decisions

## Architecture decisions

- Single organization only: no organizations table or tenant/organization IDs.
- The approved employee foundation contains users, departments, and employee profiles only.
- Customer records are external clients, not authenticating users; they have no role or permission links.
- Existing `lib/db/` Drizzle scaffold is preserved; new ERP schema changes belong in `packages/database`.

## Product

This is a single-company ERP for InterSmart. Future file binaries belong in
self-hosted MinIO; PostgreSQL stores metadata and business relationships only.
Do not introduce AWS services or SDKs for project file storage.

The internal ERP is intended to manage the complete InterSmart business
lifecycle, including external customers, sales, projects, accounts, PMO, UI,
UX, development, QA, and HR. Implement each module only when explicitly
requested. Internal employees are users; external clients are customers.

Project is the central business entity. Future Sales, Accounts, PMO, Project
Coordinator, UI, UX, Development, QA, Budget, Payments, Tasks, Meetings, Customer
Feedback, Files, Change Requests, and Notifications connect to Project.

Scope defines WHAT is included. Business Analysis defines WHY and FOR WHOM the
project exists. Budget defines HOW MUCH work is financially allocated; Tasks
define HOW the work is executed. Keep these concepts separate.

Project budgets represent internal execution funding, not customer payments.
Keep budget definitions, allocations, and transactions separate from Project;
derive financial balances from transactions rather than cached balance fields.

Customer payments are independent of internal project budgets. A payment request
can receive multiple payments or a payment can be recorded without a request.
Calculate paid/remaining from confirmed receipts; preserve overpayments and
financial history rather than deleting receipts.

UI, UX, Development, QA, PMO and other workstreams share one common task engine.
Project actions are high-level follow-ups; tasks represent executable work.
Detailed time tracking and sprint management are intentionally deferred.

UI design specifications are versioned project definitions with separate pages
and sections. UI executable work reuses common tasks through UI task links;
staffing uses ProjectTeam and UI files reuse MinIO File/ProjectResource metadata.
Daily UI status is a reporting snapshot, not authoritative task/project progress.

UX versions hold research summaries, screens and ordered flows. UX work uses
common tasks through UX task links, ProjectTeam UX roles and existing MinIO
file/resource metadata. Plan UX work with task dates/hierarchy, not UX-specific
sprints. UX daily completion is a reporting snapshot, not project source of truth.

Development uses common tasks, ProjectTeam DEV roles and MinIO resources.
Sprints are reusable project/workstream records, not Development-only sprints;
tasks may have no sprint. Repository/environment/deployment records store
metadata only, never credentials, and do not run integrations or CI/CD.

QA uses common tasks/generic sprints, the existing QA team/resource classifications
and Development environments. Bugs are defect records separate from tasks;
status history is append-only, and current-state/history writes must be atomic.
Test cases are reusable definitions; executions are individual runs. QA builds
are manually recorded metadata, not CI/CD. Daily completion is a snapshot.

System Administration stores infrastructure/server/domain/DNS/SSL/go-live,
handover and backup metadata, never secrets. Credential references identify
external secret-manager entries only. Operational assignments use common tasks
and SYSTEM_ADMIN project staffing; documents use INFRASTRUCTURE resource type.
Deployments are reused, not duplicated. Monitoring/backup/CI-CD execution is
outside this ERP; configuration flags do not configure those services.

## User preferences

- Implement only the explicitly requested database step; do not add roles or other ERP modules automatically.
- Stop after reporting each completed step and wait for the user's next instruction.
- Do not reset the database or delete approved models without explicit instruction.
- Do not build frontend screens before the database foundation is approved.

## Gotchas

- Audit/session/security tables are database foundations, not automatic logging
  or authentication. Never copy credentials, request bodies or full snapshots
  into metadata/text. Session references are independent UUIDs, never tokens.
  Generic entity references do not authorize access; preserve domain histories.

- Reporting metadata and KPI targets are not KPI actuals. Derive authorized
  aggregates from transactional sources; never persist dashboard counts/results
  in JSON configuration, add progress/financial counters or treat scope as RBAC.

- Meetings/notifications are database records only. Calendar aggregates existing
  meeting/task/action/leave/sprint dates; do not create calendar/chat/reminder
  engines or delivery workers without a separate request.
- Standalone common tasks may now be HR workstream or MEETING type (any responsible
  workstream), with no project parent/sprint. Meeting/file/entity references and
  notification preferences are not authorization grants; validate sensitive
  source records and the recipient before publishing notification content.

- HR leave/performance/complaints/appreciation are database foundations only.
  Sensitive HR records do not inherit project/customer access. Existing auth
  role/permission tables are absent; do not invent or seed an authorization system.
- HR standalone tasks/files reuse the common tables. HR files stay outside
  ProjectResource sharing; physical contents remain in MinIO. Uploader does not
  identify the employee subject. HR decision/status/balance coordination needs
  future authorized transactional writers.

_Populate as you build — sharp edges, "always run X before Y" rules._

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
