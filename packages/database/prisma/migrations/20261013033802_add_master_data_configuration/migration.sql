BEGIN;

-- CreateEnum
CREATE TYPE "NumberSequenceEntityType" AS ENUM ('USER', 'CUSTOMER', 'LEAD', 'PROPOSAL', 'PROJECT', 'TASK', 'PAYMENT_REQUEST', 'PAYMENT', 'QA_TEST_CASE', 'BUG', 'MEETING', 'LEAVE_REQUEST', 'HR_COMPLAINT', 'APPRECIATION');

-- CreateEnum
CREATE TYPE "SettingValueType" AS ENUM ('STRING', 'INTEGER', 'DECIMAL', 'BOOLEAN', 'DATE', 'JSON');

-- CreateEnum
CREATE TYPE "BusinessDayOfWeek" AS ENUM ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');

-- AlterTable
ALTER TABLE "leave_types" ADD COLUMN     "default_allocated_days" DECIMAL(10,2);

-- CreateTable
CREATE TABLE "number_sequences" (
    "id" UUID NOT NULL,
    "entity_type" "NumberSequenceEntityType" NOT NULL,
    "prefix" VARCHAR(16) NOT NULL,
    "current_value" BIGINT NOT NULL DEFAULT 0,
    "padding_length" SMALLINT NOT NULL DEFAULT 6,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "number_sequences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "system_settings" (
    "id" UUID NOT NULL,
    "key" VARCHAR(128) NOT NULL,
    "value" TEXT NOT NULL,
    "value_type" "SettingValueType" NOT NULL,
    "description" TEXT,
    "is_sensitive" BOOLEAN NOT NULL DEFAULT false,
    "is_editable" BOOLEAN NOT NULL DEFAULT true,
    "updated_by_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "system_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "feature_flags" (
    "id" UUID NOT NULL,
    "key" VARCHAR(128) NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "is_enabled" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "feature_flags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_calendar_settings" (
    "id" UUID NOT NULL,
    "day_of_week" "BusinessDayOfWeek" NOT NULL,
    "is_working_day" BOOLEAN NOT NULL,
    "working_start_time" TIME(0),
    "working_end_time" TIME(0),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "business_calendar_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "holidays" (
    "id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "holiday_date" DATE NOT NULL,
    "description" TEXT,
    "is_optional" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "holidays_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "number_sequences_entity_type_key" ON "number_sequences"("entity_type");

-- CreateIndex
CREATE INDEX "number_sequences_is_active_idx" ON "number_sequences"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "system_settings_key_key" ON "system_settings"("key");

-- CreateIndex
CREATE INDEX "system_settings_updated_by_id_idx" ON "system_settings"("updated_by_id");

-- CreateIndex
CREATE INDEX "system_settings_is_editable_is_sensitive_idx" ON "system_settings"("is_editable", "is_sensitive");

-- CreateIndex
CREATE UNIQUE INDEX "feature_flags_key_key" ON "feature_flags"("key");

-- CreateIndex
CREATE INDEX "feature_flags_is_enabled_idx" ON "feature_flags"("is_enabled");

-- CreateIndex
CREATE UNIQUE INDEX "business_calendar_settings_day_of_week_key" ON "business_calendar_settings"("day_of_week");

-- CreateIndex
CREATE INDEX "business_calendar_settings_is_working_day_idx" ON "business_calendar_settings"("is_working_day");

-- CreateIndex
CREATE INDEX "holidays_is_active_holiday_date_idx" ON "holidays"("is_active", "holiday_date");

-- CreateIndex
CREATE UNIQUE INDEX "holidays_holiday_date_name_key" ON "holidays"("holiday_date", "name");

-- AddForeignKey
ALTER TABLE "system_settings" ADD CONSTRAINT "system_settings_updated_by_id_fkey" FOREIGN KEY ("updated_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Optional defaults are not employee balances and have no seeded allocation.
ALTER TABLE "leave_types" ADD CONSTRAINT "leave_types_default_allocation_check"
CHECK ("default_allocated_days" IS NULL OR
       ("default_allocated_days" >= 0 AND "default_allocated_days" <> 'NaN'::numeric));

-- Bound the formatted code to the smallest existing code column (32 chars).
-- Padding is a minimum width, not a truncation width. Never reset/reuse counters.
ALTER TABLE "number_sequences" ADD CONSTRAINT "number_sequences_prefix_check"
CHECK ("prefix" ~ '^[A-Z][A-Z0-9_-]{0,15}$');
ALTER TABLE "number_sequences" ADD CONSTRAINT "number_sequences_counter_check"
CHECK ("current_value" BETWEEN 0 AND 9999999999999999);
ALTER TABLE "number_sequences" ADD CONSTRAINT "number_sequences_padding_check"
CHECK ("padding_length" BETWEEN 1 AND 16);

-- Database validation only, not an application configuration reader/service.
CREATE FUNCTION "erp_configuration_timezone_valid"(candidate TEXT)
RETURNS BOOLEAN LANGUAGE SQL STABLE STRICT AS $$
  SELECT EXISTS (
    SELECT 1 FROM pg_catalog.pg_timezone_names() AS tz WHERE tz.name = candidate
  );
$$;

-- Closed registry: adding a key requires a reviewed migration and consumer.
-- This is not a bag of arbitrary settings and JSON payloads.
ALTER TABLE "system_settings" ADD CONSTRAINT "system_settings_key_type_check"
CHECK (
  CASE "key"
    WHEN 'default_project_currency' THEN "value_type" = 'STRING'
    WHEN 'default_task_due_days' THEN "value_type" = 'INTEGER'
    WHEN 'default_notification_expiry_days' THEN "value_type" = 'INTEGER'
    WHEN 'company_timezone' THEN "value_type" = 'STRING'
    WHEN 'default_leave_year_start' THEN "value_type" = 'DATE'
    ELSE FALSE
  END
);
ALTER TABLE "system_settings" ADD CONSTRAINT "system_settings_value_check"
CHECK (
  CASE "key"
    WHEN 'default_project_currency' THEN "value" ~ '^[A-Z]{3}$'
    WHEN 'default_task_due_days' THEN
      CASE WHEN "value" ~ '^(0|[1-9][0-9]{0,9})$'
           THEN "value"::numeric <= 2147483647 ELSE FALSE END
    WHEN 'default_notification_expiry_days' THEN
      CASE WHEN "value" ~ '^(0|[1-9][0-9]{0,9})$'
           THEN "value"::numeric <= 2147483647 ELSE FALSE END
    WHEN 'company_timezone' THEN
      length("value") <= 128 AND "erp_configuration_timezone_valid"("value")
    WHEN 'default_leave_year_start' THEN
      CASE WHEN "value" ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
           THEN to_char("value"::date, 'YYYY-MM-DD') = "value" ELSE FALSE END
    ELSE FALSE
  END
);

ALTER TABLE "feature_flags" ADD CONSTRAINT "feature_flags_key_check"
CHECK ("key" IN (
  'new_dashboard', 'advanced_reporting', 'ai_assistant',
  'customer_portal', 'advanced_notifications'
));
ALTER TABLE "feature_flags" ADD CONSTRAINT "feature_flags_name_check"
CHECK (length(btrim("name")) > 0 AND "name" = btrim("name"));

-- Times are local wall-clock values, not instants. No overnight shift engine.
-- Unconfigured hours are a NULL pair, never an invented office schedule.
ALTER TABLE "business_calendar_settings" ADD CONSTRAINT "business_calendar_time_pair_check"
CHECK (("working_start_time" IS NULL) = ("working_end_time" IS NULL));
ALTER TABLE "business_calendar_settings" ADD CONSTRAINT "business_calendar_time_order_check"
CHECK ("working_start_time" IS NULL OR "working_start_time" < "working_end_time");

ALTER TABLE "holidays" ADD CONSTRAINT "holidays_name_check"
CHECK (length(btrim("name")) > 0 AND "name" = btrim("name"));

-- No defaults/prefixes/holiday dates/feature policies or permissions invented.
-- No audit interceptor; future authorized configuration writes use audit_logs.
COMMIT;
