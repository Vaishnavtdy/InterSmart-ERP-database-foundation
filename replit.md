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
- `pnpm --filter @workspace/database run db:migrate:dev -- --name <change-name>` — create and apply a development migration
- `pnpm --filter @workspace/database run db:migrate:deploy` — apply committed migrations
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

_Populate as you build — short repo map plus pointers to the source-of-truth file for DB schema, API contracts, theme files, etc._

## Architecture decisions

- Single organization only: no organizations table or tenant/organization IDs.
- No domain models or migration are added until the first module is approved.
- Existing `lib/db/` Drizzle scaffold is preserved; new ERP schema changes belong in `packages/database`.

## Product

_Describe the high-level user-facing capabilities of this app once they exist._

## User preferences

_Populate as you build — explicit user instructions worth remembering across sessions._

## Gotchas

_Populate as you build — sharp edges, "always run X before Y" rules._

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
