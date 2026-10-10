BEGIN;

-- CreateEnum
CREATE TYPE "PaymentType" AS ENUM ('ADVANCE', 'MILESTONE', 'FINAL', 'ADDITIONAL', 'AMC', 'RENEWAL', 'OTHER');

-- CreateEnum
CREATE TYPE "PaymentRequestStatus" AS ENUM ('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED', 'SENT', 'PARTIALLY_PAID', 'PAID', 'OVERDUE', 'CANCELLED');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('BANK_TRANSFER', 'UPI', 'CASH', 'CARD', 'CHEQUE', 'PAYPAL', 'STRIPE', 'OTHER');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'CONFIRMED', 'FAILED', 'REVERSED', 'CANCELLED');

-- CreateTable
CREATE TABLE "payment_requests" (
    "id" UUID NOT NULL,
    "payment_request_code" VARCHAR(32) NOT NULL,
    "project_id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "requested_by_id" UUID NOT NULL,
    "amount" DECIMAL(18,2) NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'INR',
    "payment_type" "PaymentType" NOT NULL,
    "description" TEXT,
    "due_date" TIMESTAMPTZ(6),
    "status" "PaymentRequestStatus" NOT NULL DEFAULT 'DRAFT',
    "requested_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "approved_at" TIMESTAMPTZ(6),
    "approved_by_id" UUID,
    "rejected_at" TIMESTAMPTZ(6),
    "rejected_by_id" UUID,
    "rejection_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "payment_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL,
    "payment_code" VARCHAR(32) NOT NULL,
    "payment_request_id" UUID,
    "project_id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "amount" DECIMAL(18,2) NOT NULL,
    "currency" VARCHAR(3) NOT NULL DEFAULT 'INR',
    "payment_method" "PaymentMethod" NOT NULL,
    "payment_date" TIMESTAMPTZ(6) NOT NULL,
    "transaction_reference" VARCHAR(255),
    "receipt_number" VARCHAR(64),
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "notes" TEXT,
    "recorded_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_status_history" (
    "id" UUID NOT NULL,
    "payment_id" UUID NOT NULL,
    "from_status" "PaymentStatus",
    "to_status" "PaymentStatus" NOT NULL,
    "changed_by_id" UUID NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_request_status_history" (
    "id" UUID NOT NULL,
    "payment_request_id" UUID NOT NULL,
    "from_status" "PaymentRequestStatus",
    "to_status" "PaymentRequestStatus" NOT NULL,
    "changed_by_id" UUID NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_request_status_history_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "payment_requests_payment_request_code_key" ON "payment_requests"("payment_request_code");

-- CreateIndex
CREATE INDEX "payment_requests_project_id_status_idx" ON "payment_requests"("project_id", "status");

-- CreateIndex
CREATE INDEX "payment_requests_customer_id_idx" ON "payment_requests"("customer_id");

-- CreateIndex
CREATE INDEX "payment_requests_requested_by_id_idx" ON "payment_requests"("requested_by_id");

-- CreateIndex
CREATE INDEX "payment_requests_approved_by_id_idx" ON "payment_requests"("approved_by_id");

-- CreateIndex
CREATE INDEX "payment_requests_rejected_by_id_idx" ON "payment_requests"("rejected_by_id");

-- CreateIndex
CREATE INDEX "payment_requests_status_deleted_at_idx" ON "payment_requests"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "payment_requests_payment_type_idx" ON "payment_requests"("payment_type");

-- CreateIndex
CREATE INDEX "payment_requests_due_date_idx" ON "payment_requests"("due_date");

-- CreateIndex
CREATE INDEX "payment_requests_created_at_idx" ON "payment_requests"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "payments_payment_code_key" ON "payments"("payment_code");

-- CreateIndex
CREATE UNIQUE INDEX "payments_receipt_number_key" ON "payments"("receipt_number");

-- CreateIndex
CREATE INDEX "payments_payment_request_id_idx" ON "payments"("payment_request_id");

-- CreateIndex
CREATE INDEX "payments_project_id_status_idx" ON "payments"("project_id", "status");

-- CreateIndex
CREATE INDEX "payments_customer_id_idx" ON "payments"("customer_id");

-- CreateIndex
CREATE INDEX "payments_status_idx" ON "payments"("status");

-- CreateIndex
CREATE INDEX "payments_payment_method_idx" ON "payments"("payment_method");

-- CreateIndex
CREATE INDEX "payments_payment_date_idx" ON "payments"("payment_date");

-- CreateIndex
CREATE INDEX "payments_recorded_by_id_idx" ON "payments"("recorded_by_id");

-- CreateIndex
CREATE INDEX "payments_created_at_idx" ON "payments"("created_at");

-- CreateIndex
CREATE INDEX "payment_status_history_payment_id_created_at_idx" ON "payment_status_history"("payment_id", "created_at");

-- CreateIndex
CREATE INDEX "payment_status_history_changed_by_id_idx" ON "payment_status_history"("changed_by_id");

-- CreateIndex
CREATE INDEX "payment_request_status_history_payment_request_id_created_a_idx" ON "payment_request_status_history"("payment_request_id", "created_at");

-- CreateIndex
CREATE INDEX "payment_request_status_history_changed_by_id_idx" ON "payment_request_status_history"("changed_by_id");

-- AddForeignKey
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_requested_by_id_fkey" FOREIGN KEY ("requested_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_rejected_by_id_fkey" FOREIGN KEY ("rejected_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_payment_request_id_fkey" FOREIGN KEY ("payment_request_id") REFERENCES "payment_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_recorded_by_id_fkey" FOREIGN KEY ("recorded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_status_history" ADD CONSTRAINT "payment_status_history_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "payments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_status_history" ADD CONSTRAINT "payment_status_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_request_status_history" ADD CONSTRAINT "payment_request_status_history_payment_request_id_fkey" FOREIGN KEY ("payment_request_id") REFERENCES "payment_requests"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_request_status_history" ADD CONSTRAINT "payment_request_status_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Row integrity only; authorization, transitions, ownership consistency,
-- currency matching, and overpayment policies remain service responsibilities.
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_amount_positive_finite_check"
CHECK ("amount" > 0 AND "amount" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric));
ALTER TABLE "payments" ADD CONSTRAINT "payments_amount_positive_finite_check"
CHECK ("amount" > 0 AND "amount" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric));
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_currency_format_check"
CHECK ("currency" ~ '^[A-Z]{3}$');
ALTER TABLE "payments" ADD CONSTRAINT "payments_currency_format_check"
CHECK ("currency" ~ '^[A-Z]{3}$');
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_approval_pair_check"
CHECK (("approved_at" IS NULL) = ("approved_by_id" IS NULL));
ALTER TABLE "payment_requests" ADD CONSTRAINT "payment_requests_rejection_pair_check"
CHECK (("rejected_at" IS NULL) = ("rejected_by_id" IS NULL));

-- Match the existing project-history append-only convention without changing it.
CREATE FUNCTION "prevent_payment_history_mutation"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Payment and payment request status history is append-only'
    USING ERRCODE = '23514';
END;
$$;

CREATE TRIGGER "payment_status_history_append_only"
BEFORE UPDATE OR DELETE ON "payment_status_history"
FOR EACH ROW EXECUTE FUNCTION "prevent_payment_history_mutation"();
CREATE TRIGGER "payment_status_history_no_truncate"
BEFORE TRUNCATE ON "payment_status_history"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_payment_history_mutation"();
CREATE TRIGGER "payment_request_status_history_append_only"
BEFORE UPDATE OR DELETE ON "payment_request_status_history"
FOR EACH ROW EXECUTE FUNCTION "prevent_payment_history_mutation"();
CREATE TRIGGER "payment_request_status_history_no_truncate"
BEFORE TRUNCATE ON "payment_request_status_history"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_payment_history_mutation"();

-- Retain every actual payment, even if later reversed or cancelled.
-- Blocking all physical deletion avoids a status downgrade/deletion loophole.
CREATE FUNCTION "prevent_payment_deletion"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Preserve payment records; use CANCELLED or REVERSED instead of deleting'
    USING ERRCODE = '23514';
END;
$$;
CREATE TRIGGER "payments_no_delete"
BEFORE DELETE ON "payments"
FOR EACH ROW EXECUTE FUNCTION "prevent_payment_deletion"();
CREATE TRIGGER "payments_no_truncate"
BEFORE TRUNCATE ON "payments"
FOR EACH STATEMENT EXECUTE FUNCTION "prevent_payment_deletion"();

COMMIT;
