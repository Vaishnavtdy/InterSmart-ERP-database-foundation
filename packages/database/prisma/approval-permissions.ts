import type { Prisma } from "../generated/client/client.js";

const approvalPermissions = [
  ["approval.read", "Read approvals"],
  ["approval.create", "Create approvals"],
  ["approval.act", "Act on approvals"],
  ["approval.manage", "Manage approvals"],
] as const;

// Permission definitions only. Never create roles, memberships or grants.
// Empty update preserves administrator-maintained names/descriptions.
export async function seedApprovalPermissions(tx: Prisma.TransactionClient) {
  for (const [code, name] of approvalPermissions) {
    await tx.permission.upsert({
      where: { code },
      update: {},
      create: { code, name },
    });
  }
}
