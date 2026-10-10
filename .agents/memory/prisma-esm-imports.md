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

## Inline verification entry points

For `tsx -e` checks, import the generated TypeScript entry with an explicit
`.ts` extension. Keep `.js` imports in ordinary NodeNext source files.

**Why:** Inline evaluation uses a synthetic caller rather than a TypeScript
source file, so its resolver may not remap a relative `.js` entry to the
generated `.ts` file, even though the same import works in a normal script.

**How to apply:** Prefer a real TypeScript entry point for reusable checks;
when using inline evaluation, distinguish entry-point resolution errors from
application or database failures.
