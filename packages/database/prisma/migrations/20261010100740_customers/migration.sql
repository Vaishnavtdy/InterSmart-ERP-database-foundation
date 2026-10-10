BEGIN;

-- CreateEnum
CREATE TYPE "CustomerStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'PROSPECT', 'BLOCKED');

-- CreateEnum
CREATE TYPE "CustomerContactStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- CreateTable
CREATE TABLE "customers" (
    "id" UUID NOT NULL,
    "customer_code" VARCHAR(32) NOT NULL,
    "company_name" VARCHAR(255) NOT NULL,
    "website" VARCHAR(2048),
    "industry" VARCHAR(120),
    "country" VARCHAR(100),
    "state" VARCHAR(100),
    "city" VARCHAR(100),
    "address" TEXT,
    "source" VARCHAR(120),
    "status" "CustomerStatus" NOT NULL DEFAULT 'PROSPECT',
    "assigned_salesperson_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "customers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "customer_contacts" (
    "id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100),
    "email" VARCHAR(320),
    "phone" VARCHAR(32),
    "designation" VARCHAR(120),
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "status" "CustomerContactStatus" NOT NULL DEFAULT 'ACTIVE',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "customer_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "customers_customer_code_key" ON "customers"("customer_code");

-- CreateIndex
CREATE INDEX "customers_company_name_idx" ON "customers"("company_name");

-- CreateIndex
CREATE INDEX "customers_status_deleted_at_idx" ON "customers"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "customers_assigned_salesperson_id_idx" ON "customers"("assigned_salesperson_id");

-- CreateIndex
CREATE INDEX "customer_contacts_customer_id_idx" ON "customer_contacts"("customer_id");

-- CreateIndex
CREATE INDEX "customer_contacts_email_idx" ON "customer_contacts"("email");

-- CreateIndex
CREATE INDEX "customer_contacts_phone_idx" ON "customer_contacts"("phone");

-- Each customer may have many contacts, but at most one primary contact.
CREATE UNIQUE INDEX "customer_contacts_one_primary_per_customer_key"
ON "customer_contacts"("customer_id") WHERE "is_primary" = true;

-- AddForeignKey
ALTER TABLE "customers" ADD CONSTRAINT "customers_assigned_salesperson_id_fkey" FOREIGN KEY ("assigned_salesperson_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "customer_contacts" ADD CONSTRAINT "customer_contacts_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT;
