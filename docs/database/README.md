# Database

InterSmart ERP uses PostgreSQL with Prisma. The Prisma package and schema are
located in `packages/database/`.

## Requirements

- Set `DATABASE_URL` to the PostgreSQL connection string through the workspace
  secrets/environment settings. Do not commit connection strings.
- Use Prisma Migrate for schema changes; do not use schema push or reset
  commands against an existing database.

## Commands

Run from the repository root:

```sh
pnpm --filter @workspace/database run db:format
pnpm --filter @workspace/database run db:validate
pnpm --filter @workspace/database run db:generate
pnpm --filter @workspace/database run db:migrate:dev -- --name <change-name>
pnpm --filter @workspace/database run db:migrate:deploy
pnpm --filter @workspace/database run db:migrate:status
```

`db:migrate:dev` is for local development and creates a migration from a
reviewed schema change. `db:migrate:deploy` applies committed migrations and is
intended for controlled deployment workflows.

## Employee foundation

The approved employee foundation contains `users`, `departments`, and
`employee_profiles`. The nine department codes are seeded by the idempotent
`db:seed` command. No roles or other ERP modules are included.

For a new database, create and apply a development migration with:

```sh
pnpm --filter @workspace/database run db:migrate:dev -- --name employee-foundation
pnpm --filter @workspace/database run db:seed
```

The seed only inserts missing departments and does not create user accounts.

`users.deleted_at` is a nullable soft-delete marker. Employee codes and email
addresses remain unique even after soft deletion so historical identifiers are
not reused.

The existing Drizzle scaffold under `lib/db/` is preserved and has not been
converted or deleted in this step. New ERP schema work belongs in
`packages/database/prisma/schema.prisma`.
