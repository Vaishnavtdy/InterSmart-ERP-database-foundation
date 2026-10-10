BEGIN;

-- CreateEnum
CREATE TYPE "LeadStatus" AS ENUM ('NEW', 'FOLLOW_UP', 'MEETING', 'PROPOSAL', 'READY_TO_CLOSE', 'WON', 'LOST');

-- CreateEnum
CREATE TYPE "LeadTemperature" AS ENUM ('COLD', 'WARM', 'HOT');

-- CreateEnum
CREATE TYPE "LeadSource" AS ENUM ('WEBSITE', 'REFERRAL', 'SOCIAL_MEDIA', 'ADVERTISEMENT', 'COLD_CALL', 'EMAIL', 'DIRECT', 'EXISTING_CUSTOMER', 'OTHER');

-- CreateEnum
CREATE TYPE "LeadActivityType" AS ENUM ('CALL', 'EMAIL', 'MEETING', 'FOLLOW_UP', 'PROPOSAL', 'NOTE', 'WHATSAPP', 'OTHER');

-- CreateTable
CREATE TABLE "leads" (
    "id" UUID NOT NULL,
    "lead_code" VARCHAR(32) NOT NULL,
    "customer_id" UUID,
    "assigned_to_id" UUID NOT NULL,
    "source" "LeadSource" NOT NULL,
    "contact_name" VARCHAR(200) NOT NULL,
    "email" VARCHAR(320),
    "phone" VARCHAR(32),
    "company_name" VARCHAR(255),
    "requirement" TEXT,
    "estimated_value" DECIMAL(18,2),
    "expected_close_date" TIMESTAMPTZ(6),
    "status" "LeadStatus" NOT NULL DEFAULT 'NEW',
    "temperature" "LeadTemperature" NOT NULL DEFAULT 'COLD',
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "leads_pkey" PRIMARY KEY ("id")
);

-- Unknown estimated value is nullable; known values must not be negative.
ALTER TABLE "leads" ADD CONSTRAINT "leads_estimated_value_nonnegative_check"
CHECK ("estimated_value" IS NULL OR "estimated_value" >= 0);

-- CreateTable
CREATE TABLE "lead_activities" (
    "id" UUID NOT NULL,
    "lead_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "activity_type" "LeadActivityType" NOT NULL,
    "subject" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "scheduled_at" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "next_follow_up_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lead_activities_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "leads_lead_code_key" ON "leads"("lead_code");

-- CreateIndex
CREATE INDEX "leads_customer_id_idx" ON "leads"("customer_id");

-- CreateIndex
CREATE INDEX "leads_assigned_to_id_status_deleted_at_idx" ON "leads"("assigned_to_id", "status", "deleted_at");

-- CreateIndex
CREATE INDEX "leads_status_deleted_at_idx" ON "leads"("status", "deleted_at");

-- CreateIndex
CREATE INDEX "leads_temperature_deleted_at_idx" ON "leads"("temperature", "deleted_at");

-- CreateIndex
CREATE INDEX "leads_expected_close_date_idx" ON "leads"("expected_close_date");

-- CreateIndex
CREATE INDEX "leads_created_at_idx" ON "leads"("created_at");

-- CreateIndex
CREATE INDEX "lead_activities_lead_id_created_at_idx" ON "lead_activities"("lead_id", "created_at");

-- CreateIndex
CREATE INDEX "lead_activities_user_id_next_follow_up_at_idx" ON "lead_activities"("user_id", "next_follow_up_at");

-- CreateIndex
CREATE INDEX "lead_activities_activity_type_idx" ON "lead_activities"("activity_type");

-- CreateIndex
CREATE INDEX "lead_activities_scheduled_at_idx" ON "lead_activities"("scheduled_at");

-- CreateIndex
CREATE INDEX "lead_activities_next_follow_up_at_idx" ON "lead_activities"("next_follow_up_at");

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leads" ADD CONSTRAINT "leads_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_lead_id_fkey" FOREIGN KEY ("lead_id") REFERENCES "leads"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lead_activities" ADD CONSTRAINT "lead_activities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

COMMIT;
