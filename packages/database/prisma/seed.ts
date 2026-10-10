import { PrismaPg } from "@prisma/adapter-pg";
import { DepartmentCode, PrismaClient } from "../generated/client/client";

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  throw new Error("DATABASE_URL is required to seed department records.");
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
  for (const code of departmentCodes) {
    await prisma.department.upsert({
      where: { code },
      update: {},
      create: { code },
    });
  }
} finally {
  await prisma.$disconnect();
}
