BEGIN;

-- CreateEnum
CREATE TYPE "ProjectBudgetStatus" AS ENUM ('DRAFT', 'ACTIVE', 'ON_HOLD', 'CLOSED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "BudgetAllocationType" AS ENUM ('PROJECT_MANAGEMENT', 'BUSINESS_ANALYSIS', 'UI', 'UX', 'DEVELOPMENT', 'QA', 'INFRASTRUCTURE', 'OTHER');

-- CreateEnum
CREATE TYPE "BudgetTransactionType" AS ENUM ('INITIAL_ALLOCATION', 'ALLOCATION', 'ADJUSTMENT', 'INCREASE', 'DECREASE', 'EXPENSE', 'REFUND', 'REVERSAL');

-- CreateTable
CREATE TABLE "project_budgets" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "total_budget" DECIMAL(18,2) NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'INR',
    "status" "ProjectBudgetStatus" NOT NULL DEFAULT 'DRAFT',
    "effective_from" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "effective_until" TIMESTAMPTZ(6),
    "notes" TEXT,
    "created_by_id" UUID NOT NULL,
    "updated_by_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_budgets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "budget_allocations" (
    "id" UUID NOT NULL,
    "project_budget_id" UUID NOT NULL,
    "department_id" UUID,
    "user_id" UUID,
    "allocation_type" "BudgetAllocationType" NOT NULL,
    "allocated_amount" DECIMAL(18,2) NOT NULL,
    "description" TEXT,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "budget_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "budget_transactions" (
    "id" UUID NOT NULL,
    "project_budget_id" UUID NOT NULL,
    "allocation_id" UUID,
    "transaction_type" "BudgetTransactionType" NOT NULL,
    "amount" DECIMAL(18,2) NOT NULL,
    "reference" VARCHAR(255),
    "description" TEXT,
    "transaction_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "budget_transactions_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "project_budgets_project_id_key" ON "project_budgets"("project_id");

-- CreateIndex
CREATE INDEX "project_budgets_status_idx" ON "project_budgets"("status");

-- CreateIndex
CREATE INDEX "project_budgets_created_at_idx" ON "project_budgets"("created_at");

-- CreateIndex
CREATE INDEX "project_budgets_created_by_id_idx" ON "project_budgets"("created_by_id");

-- CreateIndex
CREATE INDEX "project_budgets_updated_by_id_idx" ON "project_budgets"("updated_by_id");

-- CreateIndex
CREATE INDEX "budget_allocations_project_budget_id_allocation_type_idx" ON "budget_allocations"("project_budget_id", "allocation_type");

-- CreateIndex
CREATE INDEX "budget_allocations_department_id_idx" ON "budget_allocations"("department_id");

-- CreateIndex
CREATE INDEX "budget_allocations_user_id_idx" ON "budget_allocations"("user_id");

-- CreateIndex
CREATE INDEX "budget_allocations_allocation_type_idx" ON "budget_allocations"("allocation_type");

-- CreateIndex
CREATE INDEX "budget_allocations_created_by_id_idx" ON "budget_allocations"("created_by_id");

-- CreateIndex
CREATE INDEX "budget_allocations_created_at_idx" ON "budget_allocations"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "budget_allocations_project_budget_id_id_key" ON "budget_allocations"("project_budget_id", "id");

-- CreateIndex
CREATE INDEX "budget_transactions_project_budget_id_transaction_date_idx" ON "budget_transactions"("project_budget_id", "transaction_date");

-- CreateIndex
CREATE INDEX "budget_transactions_allocation_id_idx" ON "budget_transactions"("allocation_id");

-- CreateIndex
CREATE INDEX "budget_transactions_transaction_type_idx" ON "budget_transactions"("transaction_type");

-- CreateIndex
CREATE INDEX "budget_transactions_transaction_date_idx" ON "budget_transactions"("transaction_date");

-- CreateIndex
CREATE INDEX "budget_transactions_created_by_id_idx" ON "budget_transactions"("created_by_id");

-- CreateIndex
CREATE INDEX "budget_transactions_created_at_idx" ON "budget_transactions"("created_at");

-- AddForeignKey
ALTER TABLE "project_budgets" ADD CONSTRAINT "project_budgets_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_budgets" ADD CONSTRAINT "project_budgets_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_budgets" ADD CONSTRAINT "project_budgets_updated_by_id_fkey" FOREIGN KEY ("updated_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_allocations" ADD CONSTRAINT "budget_allocations_project_budget_id_fkey" FOREIGN KEY ("project_budget_id") REFERENCES "project_budgets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_allocations" ADD CONSTRAINT "budget_allocations_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_allocations" ADD CONSTRAINT "budget_allocations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_allocations" ADD CONSTRAINT "budget_allocations_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_transactions" ADD CONSTRAINT "budget_transactions_project_budget_id_fkey" FOREIGN KEY ("project_budget_id") REFERENCES "project_budgets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "budget_transactions" ADD CONSTRAINT "budget_transactions_project_budget_id_allocation_id_fkey" FOREIGN KEY ("project_budget_id", "allocation_id") REFERENCES "budget_allocations"("project_budget_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "budget_transactions" ADD CONSTRAINT "budget_transactions_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Simple row integrity only: workflow/aggregation rules remain in future services.
ALTER TABLE "project_budgets" ADD CONSTRAINT "project_budgets_total_nonnegative_finite_check"
CHECK ("total_budget" >= 0 AND "total_budget" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric));

ALTER TABLE "project_budgets" ADD CONSTRAINT "project_budgets_currency_format_check"
CHECK ("currency" ~ '^[A-Z]{3}$');

ALTER TABLE "project_budgets" ADD CONSTRAINT "project_budgets_effective_date_order_check"
CHECK ("effective_until" IS NULL OR "effective_until" >= "effective_from");

ALTER TABLE "budget_allocations" ADD CONSTRAINT "budget_allocations_amount_nonnegative_finite_check"
CHECK ("allocated_amount" >= 0 AND "allocated_amount" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric));

ALTER TABLE "budget_transactions" ADD CONSTRAINT "budget_transactions_amount_nonzero_finite_check"
CHECK ("amount" <> 0 AND "amount" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric));

ALTER TABLE "budget_transactions" ADD CONSTRAINT "budget_transactions_amount_direction_check"
CHECK (
    ("transaction_type" IN ('INITIAL_ALLOCATION', 'INCREASE', 'REFUND') AND "amount" > 0)
    OR ("transaction_type" IN ('DECREASE', 'EXPENSE') AND "amount" < 0)
    OR "transaction_type" IN ('ADJUSTMENT', 'ALLOCATION', 'REVERSAL')
);

COMMIT;
