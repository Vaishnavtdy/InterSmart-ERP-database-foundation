BEGIN;

-- CreateEnum
CREATE TYPE "ProposalStatus" AS ENUM ('DRAFT', 'SENT', 'UNDER_NEGOTIATION', 'ACCEPTED', 'REJECTED', 'EXPIRED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "ProposalVersionStatus" AS ENUM ('DRAFT', 'ACTIVE', 'SUPERSEDED', 'ACCEPTED', 'REJECTED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "DiscountType" AS ENUM ('PERCENTAGE', 'FIXED');

-- CreateTable
CREATE TABLE "proposals" (
    "id" UUID NOT NULL,
    "proposal_code" VARCHAR(32) NOT NULL,
    "lead_id" UUID,
    "customer_id" UUID NOT NULL,
    "created_by_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "status" "ProposalStatus" NOT NULL DEFAULT 'DRAFT',
    "current_version_id" UUID,
    "valid_until" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "proposals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "proposal_versions" (
    "id" UUID NOT NULL,
    "proposal_id" UUID NOT NULL,
    "version_number" INTEGER NOT NULL,
    "status" "ProposalVersionStatus" NOT NULL DEFAULT 'DRAFT',
    "subtotal" DECIMAL(18,2) NOT NULL,
    "discount_amount" DECIMAL(18,2) NOT NULL,
    "tax_amount" DECIMAL(18,2) NOT NULL,
    "total_amount" DECIMAL(18,2) NOT NULL,
    "notes" TEXT,
    "valid_until" TIMESTAMPTZ(6),
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sent_at" TIMESTAMPTZ(6),
    "accepted_at" TIMESTAMPTZ(6),
    "rejected_at" TIMESTAMPTZ(6),
    "rejection_reason" TEXT,

    CONSTRAINT "proposal_versions_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "proposal_versions" ADD CONSTRAINT "proposal_versions_version_number_positive_check"
CHECK ("version_number" > 0);

ALTER TABLE "proposal_versions" ADD CONSTRAINT "proposal_versions_amounts_nonnegative_check"
CHECK (
    "subtotal" >= 0 AND "subtotal" <> 'NaN'::numeric
    AND "discount_amount" >= 0 AND "discount_amount" <> 'NaN'::numeric
    AND "tax_amount" >= 0 AND "tax_amount" <> 'NaN'::numeric
    AND "total_amount" >= 0 AND "total_amount" <> 'NaN'::numeric
);

-- CreateTable
CREATE TABLE "proposal_items" (
    "id" UUID NOT NULL,
    "proposal_version_id" UUID NOT NULL,
    "description" TEXT NOT NULL,
    "quantity" DECIMAL(18,4) NOT NULL DEFAULT 1,
    "unit_price" DECIMAL(18,2) NOT NULL,
    "discount_type" "DiscountType",
    "discount_value" DECIMAL(18,2),
    "amount" DECIMAL(18,2) NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "proposal_items_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "proposal_items" ADD CONSTRAINT "proposal_items_quantity_positive_check"
CHECK ("quantity" > 0 AND "quantity" <> 'NaN'::numeric);

ALTER TABLE "proposal_items" ADD CONSTRAINT "proposal_items_amounts_nonnegative_check"
CHECK (
    "unit_price" >= 0 AND "unit_price" <> 'NaN'::numeric
    AND "amount" >= 0 AND "amount" <> 'NaN'::numeric
);

ALTER TABLE "proposal_items" ADD CONSTRAINT "proposal_items_discount_check"
CHECK (
    ("discount_type" IS NULL AND "discount_value" IS NULL)
    OR (
        "discount_type" IS NOT NULL AND "discount_value" IS NOT NULL
        AND "discount_value" >= 0 AND "discount_value" <> 'NaN'::numeric
        AND ("discount_type" <> 'PERCENTAGE' OR "discount_value" <= 100)
    )
);

ALTER TABLE "proposal_items" ADD CONSTRAINT "proposal_items_sort_order_nonnegative_check"
CHECK ("sort_order" >= 0);

-- CreateIndex
CREATE UNIQUE INDEX "proposals_proposal_code_key" ON "proposals"("proposal_code");

-- CreateIndex
CREATE INDEX "proposals_lead_id_idx" ON "proposals"("lead_id");

-- CreateIndex
CREATE INDEX "proposals_customer_id_idx" ON "proposals"("customer_id");

-- CreateIndex
CREATE INDEX "proposals_created_by_id_idx" ON "proposals"("created_by_id");

-- CreateIndex
CREATE INDEX "proposals_status_deleted_at_idx" ON "proposals"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "proposals_valid_until_idx" ON "proposals"("valid_until");

-- CreateIndex
CREATE INDEX "proposal_versions_created_by_id_idx" ON "proposal_versions"("created_by_id");

-- CreateIndex
CREATE INDEX "proposal_versions_status_idx" ON "proposal_versions"("status");

-- CreateIndex
CREATE INDEX "proposal_versions_created_at_idx" ON "proposal_versions"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "proposal_versions_proposal_id_version_number_key" ON "proposal_versions"("proposal_id", "version_number");

-- CreateIndex
CREATE UNIQUE INDEX "proposal_versions_proposal_id_id_key" ON "proposal_versions"("proposal_id", "id");

-- CreateIndex
CREATE INDEX "proposal_items_proposal_version_id_sort_order_idx" ON "proposal_items"("proposal_version_id", "sort_order");

-- AddForeignKey
ALTER TABLE "proposals" ADD CONSTRAINT "proposals_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "proposals" ADD CONSTRAINT "proposals_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "proposals" ADD CONSTRAINT "proposals_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "proposals" ADD CONSTRAINT "proposals_id_current_version_id_fkey" FOREIGN KEY ("id", "current_version_id") REFERENCES "proposal_versions"("proposal_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "proposal_versions" ADD CONSTRAINT "proposal_versions_proposal_id_fkey" FOREIGN KEY ("proposal_id") REFERENCES "proposals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "proposal_versions" ADD CONSTRAINT "proposal_versions_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "proposal_items" ADD CONSTRAINT "proposal_items_proposal_version_id_fkey" FOREIGN KEY ("proposal_version_id") REFERENCES "proposal_versions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

COMMIT;
