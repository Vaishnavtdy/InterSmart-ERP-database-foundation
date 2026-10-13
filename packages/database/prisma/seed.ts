import { PrismaPg } from "@prisma/adapter-pg";
import { DepartmentCode, PrismaClient } from "../generated/client/client.js";
import { seedProjectCategories } from "./project-categories.js";
import { seedApprovalPermissions } from "./approval-permissions.js";

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  throw new Error("DATABASE_URL is required to seed reference records.");
}

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: databaseUrl }),
});

const departmentCodes = [
  DepartmentCode.SALES,
  DepartmentCode.ACCOUNTS,
  DepartmentCode.PMO,
  DepartmentCode.UI,
  DepartmentCode.UX,
  DepartmentCode.DEVELOPMENT,
  DepartmentCode.QA,
  DepartmentCode.HR,
  DepartmentCode.MANAGEMENT,
];

try {
  await prisma.$transaction(async (tx) => {
    for (const code of departmentCodes) {
      await tx.department.upsert({
        where: { code },
        update: {},
        create: { code },
      });
    }
    await seedProjectCategories(tx);
    await seedApprovalPermissions(tx);
  }, { timeout: 30_000 });
} finally {
  await prisma.$disconnect();
}
