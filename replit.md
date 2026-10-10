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

The internal ERP is intended to manage the complete InterSmart business
lifecycle, including external customers, sales, projects, accounts, PMO, UI,
UX, development, QA, and HR. Implement each module only when explicitly
requested. Internal employees are users; external clients are customers.

Project is the central business entity. Future Sales, Accounts, PMO, Project
Coordinator, UI, UX, Development, QA, Budget, Payments, Tasks, Meetings, Customer
Feedback, Files, Change Requests, and Notifications connect to Project.

## User preferences

- Implement only the explicitly requested database step; do not add roles or other ERP modules automatically.
- Stop after reporting each completed step and wait for the user's next instruction.
- Do not reset the database or delete approved models without explicit instruction.
- Do not build frontend screens before the database foundation is approved.

## Gotchas

_Populate as you build — sharp edges, "always run X before Y" rules._

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
