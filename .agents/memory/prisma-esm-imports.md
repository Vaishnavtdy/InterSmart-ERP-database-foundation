---
name: Prisma ESM imports
description: Prisma's TypeScript client generation and NodeNext module resolution
---

With Prisma's `prisma-client` TypeScript generator and NodeNext checks, use
explicit `.js` imports throughout the generated client, not only at its caller.

**Why:** The generator's default extensionless internal imports can leave enum
re-exports unresolved under NodeNext. Changing only the seed's external import
to `.js` does not fix that internal resolution problem.

**How to apply:** Configure the generator with `importFileExtension = "js"`,
use `.js` relative imports in NodeNext callers, and use `tsx` when executing
the generated TypeScript directly. Validate with the package's NodeNext
TypeScript check after generation.
