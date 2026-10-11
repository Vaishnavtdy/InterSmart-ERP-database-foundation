BEGIN;

-- CreateEnum
CREATE TYPE "ReportType" AS ENUM ('DASHBOARD', 'TABLE', 'SUMMARY', 'ANALYTICS', 'EXPORT');

-- CreateEnum
CREATE TYPE "ReportingScope" AS ENUM ('GLOBAL', 'SALES', 'ACCOUNTS', 'PMO', 'PROJECT', 'UI', 'UX', 'DEVELOPMENT', 'QA', 'HR', 'EMPLOYEE');

-- CreateEnum
CREATE TYPE "DashboardWidgetType" AS ENUM ('KPI', 'TABLE', 'BAR_CHART', 'LINE_CHART', 'PIE_CHART', 'DONUT_CHART', 'PROGRESS', 'LIST', 'TREND');

-- CreateEnum
CREATE TYPE "KpiCategory" AS ENUM ('PROJECT', 'SALES', 'FINANCE', 'OPERATIONS', 'QUALITY', 'HR', 'RESOURCE', 'CUSTOMER');

-- CreateEnum
CREATE TYPE "KpiScope" AS ENUM ('GLOBAL', 'SALES', 'ACCOUNTS', 'PMO', 'UI', 'UX', 'DEVELOPMENT', 'QA', 'HR', 'EMPLOYEE');

-- CreateEnum
CREATE TYPE "KpiUnit" AS ENUM ('COUNT', 'PERCENTAGE', 'CURRENCY', 'HOURS', 'DAYS', 'RATIO', 'OTHER');

-- CreateTable
CREATE TABLE "reports" (
    "id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "description" TEXT,
    "report_type" "ReportType" NOT NULL,
    "scope" "ReportingScope" NOT NULL,
    "is_system" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "report_configurations" (
    "id" UUID NOT NULL,
    "report_id" UUID NOT NULL,
    "configuration" JSONB NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "report_configurations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "saved_reports" (
    "id" UUID NOT NULL,
    "report_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "configuration" JSONB NOT NULL,
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "saved_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dashboards" (
    "id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "description" TEXT,
    "scope" "ReportingScope" NOT NULL,
    "is_system" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "dashboards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dashboard_widgets" (
    "id" UUID NOT NULL,
    "dashboard_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "widget_type" "DashboardWidgetType" NOT NULL,
    "data_source" VARCHAR(128) NOT NULL,
    "configuration" JSONB NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "dashboard_widgets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_dashboard_preferences" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "dashboard_id" UUID NOT NULL,
    "layout" JSONB NOT NULL,
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "user_dashboard_preferences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "kpi_definitions" (
    "id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(64) NOT NULL,
    "description" TEXT,
    "category" "KpiCategory" NOT NULL,
    "scope" "KpiScope" NOT NULL,
    "unit" "KpiUnit" NOT NULL,
    "calculation_key" VARCHAR(128) NOT NULL,
    "target_value" DECIMAL(20,4),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "kpi_definitions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "kpi_targets" (
    "id" UUID NOT NULL,
    "kpi_definition_id" UUID NOT NULL,
    "target_value" DECIMAL(20,4) NOT NULL,
    "effective_from" TIMESTAMPTZ(6) NOT NULL,
    "effective_until" TIMESTAMPTZ(6),
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "kpi_targets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "kpi_assignments" (
    "id" UUID NOT NULL,
    "kpi_definition_id" UUID NOT NULL,
    "user_id" UUID,
    "department_id" UUID,
    "target_value" DECIMAL(20,4),
    "effective_from" TIMESTAMPTZ(6) NOT NULL,
    "effective_until" TIMESTAMPTZ(6),
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "kpi_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "reports_code_key" ON "reports"("code");

-- CreateIndex
CREATE INDEX "reports_scope_is_active_idx" ON "reports"("scope", "is_active");

-- CreateIndex
CREATE INDEX "reports_report_type_idx" ON "reports"("report_type");

-- CreateIndex
CREATE INDEX "reports_created_by_id_idx" ON "reports"("created_by_id");

-- CreateIndex
CREATE INDEX "report_configurations_created_by_id_idx" ON "report_configurations"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "report_configurations_report_id_version_key" ON "report_configurations"("report_id", "version");

-- CreateIndex
CREATE INDEX "saved_reports_report_id_idx" ON "saved_reports"("report_id");

-- CreateIndex
CREATE UNIQUE INDEX "saved_reports_user_id_report_id_name_key" ON "saved_reports"("user_id", "report_id", "name");

-- CreateIndex
CREATE UNIQUE INDEX "dashboards_code_key" ON "dashboards"("code");

-- CreateIndex
CREATE INDEX "dashboards_scope_is_active_idx" ON "dashboards"("scope", "is_active");

-- CreateIndex
CREATE INDEX "dashboard_widgets_dashboard_id_is_active_sort_order_idx" ON "dashboard_widgets"("dashboard_id", "is_active", "sort_order");

-- CreateIndex
CREATE UNIQUE INDEX "dashboard_widgets_dashboard_id_code_key" ON "dashboard_widgets"("dashboard_id", "code");

-- CreateIndex
CREATE INDEX "user_dashboard_preferences_dashboard_id_idx" ON "user_dashboard_preferences"("dashboard_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_dashboard_preferences_user_id_dashboard_id_key" ON "user_dashboard_preferences"("user_id", "dashboard_id");

-- CreateIndex
CREATE UNIQUE INDEX "kpi_definitions_code_key" ON "kpi_definitions"("code");

-- CreateIndex
CREATE INDEX "kpi_definitions_scope_is_active_idx" ON "kpi_definitions"("scope", "is_active");

-- CreateIndex
CREATE INDEX "kpi_definitions_category_idx" ON "kpi_definitions"("category");

-- CreateIndex
CREATE INDEX "kpi_definitions_calculation_key_idx" ON "kpi_definitions"("calculation_key");

-- CreateIndex
CREATE INDEX "kpi_targets_kpi_definition_id_effective_from_idx" ON "kpi_targets"("kpi_definition_id", "effective_from");

-- CreateIndex
CREATE INDEX "kpi_targets_effective_until_idx" ON "kpi_targets"("effective_until");

-- CreateIndex
CREATE INDEX "kpi_targets_created_by_id_idx" ON "kpi_targets"("created_by_id");

-- CreateIndex
CREATE INDEX "kpi_assignments_kpi_definition_id_effective_from_idx" ON "kpi_assignments"("kpi_definition_id", "effective_from");

-- CreateIndex
CREATE INDEX "kpi_assignments_user_id_kpi_definition_id_effective_from_idx" ON "kpi_assignments"("user_id", "kpi_definition_id", "effective_from");

-- CreateIndex
CREATE INDEX "kpi_assignments_department_id_kpi_definition_id_effective_f_idx" ON "kpi_assignments"("department_id", "kpi_definition_id", "effective_from");

-- CreateIndex
CREATE INDEX "kpi_assignments_effective_until_idx" ON "kpi_assignments"("effective_until");

-- CreateIndex
CREATE INDEX "kpi_assignments_created_by_id_idx" ON "kpi_assignments"("created_by_id");

-- CreateIndex
CREATE INDEX "projects_start_date_idx" ON "projects"("start_date");

-- AddForeignKey
ALTER TABLE "reports" ADD CONSTRAINT "reports_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_configurations" ADD CONSTRAINT "report_configurations_report_id_fkey" FOREIGN KEY ("report_id") REFERENCES "reports"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_configurations" ADD CONSTRAINT "report_configurations_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_reports" ADD CONSTRAINT "saved_reports_report_id_fkey" FOREIGN KEY ("report_id") REFERENCES "reports"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_reports" ADD CONSTRAINT "saved_reports_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dashboard_widgets" ADD CONSTRAINT "dashboard_widgets_dashboard_id_fkey" FOREIGN KEY ("dashboard_id") REFERENCES "dashboards"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_dashboard_preferences" ADD CONSTRAINT "user_dashboard_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_dashboard_preferences" ADD CONSTRAINT "user_dashboard_preferences_dashboard_id_fkey" FOREIGN KEY ("dashboard_id") REFERENCES "dashboards"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "kpi_targets" ADD CONSTRAINT "kpi_targets_kpi_definition_id_fkey" FOREIGN KEY ("kpi_definition_id") REFERENCES "kpi_definitions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "kpi_targets" ADD CONSTRAINT "kpi_targets_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "kpi_assignments" ADD CONSTRAINT "kpi_assignments_kpi_definition_id_fkey" FOREIGN KEY ("kpi_definition_id") REFERENCES "kpi_definitions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "kpi_assignments" ADD CONSTRAINT "kpi_assignments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "kpi_assignments" ADD CONSTRAINT "kpi_assignments_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "kpi_assignments" ADD CONSTRAINT "kpi_assignments_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Only structured configuration objects, not JSON null/scalars/result arrays.
-- Application schemas must still whitelist metadata and reject result payloads.
ALTER TABLE "report_configurations" ADD CONSTRAINT "report_configuration_object_check"
CHECK (jsonb_typeof("configuration") = 'object');
ALTER TABLE "saved_reports" ADD CONSTRAINT "saved_report_configuration_object_check"
CHECK (jsonb_typeof("configuration") = 'object');
ALTER TABLE "dashboard_widgets" ADD CONSTRAINT "dashboard_widget_configuration_object_check"
CHECK (jsonb_typeof("configuration") = 'object');
ALTER TABLE "user_dashboard_preferences" ADD CONSTRAINT "dashboard_layout_object_check"
CHECK (jsonb_typeof("layout") = 'object');
ALTER TABLE "report_configurations" ADD CONSTRAINT "report_configuration_positive_version_check"
CHECK ("version" > 0);
ALTER TABLE "dashboard_widgets" ADD CONSTRAINT "dashboard_widget_sort_order_check"
CHECK ("sort_order" >= 0);
ALTER TABLE "dashboard_widgets" ADD CONSTRAINT "dashboard_widget_data_source_check"
CHECK (length(btrim("data_source")) > 0);
ALTER TABLE "kpi_definitions" ADD CONSTRAINT "kpi_calculation_key_check"
CHECK (length(btrim("calculation_key")) > 0);

-- Half-open periods [effective_from, effective_until); NULL has no upper bound.
-- Overlap and target-precedence rules remain future business/service decisions.
ALTER TABLE "kpi_targets" ADD CONSTRAINT "kpi_target_period_check"
CHECK ("effective_until" IS NULL OR "effective_until" > "effective_from");
ALTER TABLE "kpi_assignments" ADD CONSTRAINT "kpi_assignment_period_check"
CHECK ("effective_until" IS NULL OR "effective_until" > "effective_from");
ALTER TABLE "kpi_assignments" ADD CONSTRAINT "kpi_assignment_subject_check"
CHECK (num_nonnulls("user_id", "department_id") = 1);

-- Targets are policy definitions, not actual values. Generic targets may be
-- negative (e.g. a signed net metric); unit-specific bounds are not invented.
ALTER TABLE "kpi_definitions" ADD CONSTRAINT "kpi_definition_finite_target_check"
CHECK ("target_value" IS NULL OR "target_value" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric));
ALTER TABLE "kpi_targets" ADD CONSTRAINT "kpi_target_finite_value_check"
CHECK ("target_value" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric));
ALTER TABLE "kpi_assignments" ADD CONSTRAINT "kpi_assignment_finite_target_check"
CHECK ("target_value" IS NULL OR "target_value" NOT IN ('NaN'::numeric, 'Infinity'::numeric, '-Infinity'::numeric));

COMMIT;
