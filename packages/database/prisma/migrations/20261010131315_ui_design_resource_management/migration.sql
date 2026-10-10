BEGIN;

-- CreateEnum
CREATE TYPE "UiStatus" AS ENUM ('DRAFT', 'IN_PROGRESS', 'IN_REVIEW', 'APPROVED', 'REWORK', 'COMPLETED', 'ON_HOLD', 'CANCELLED');

-- CreateEnum
CREATE TYPE "UiPageType" AS ENUM ('PUBLIC', 'AUTHENTICATION', 'DASHBOARD', 'ADMIN', 'CONTENT', 'E_COMMERCE', 'SYSTEM', 'OTHER');

-- CreateEnum
CREATE TYPE "UiPageStatus" AS ENUM ('PLANNED', 'IN_DESIGN', 'IN_REVIEW', 'APPROVED', 'REWORK', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "UiSectionType" AS ENUM ('HEADER', 'NAVIGATION', 'HERO', 'CONTENT', 'FEATURES', 'GALLERY', 'TESTIMONIALS', 'PRICING', 'FORM', 'CTA', 'FOOTER', 'CUSTOM');

-- CreateEnum
CREATE TYPE "UiDesignLinkType" AS ENUM ('FIGMA', 'PROTOTYPE', 'DESIGN_SYSTEM', 'REFERENCE', 'OTHER');

-- CreateTable
CREATE TABLE "project_ui" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "version_number" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "status" "UiStatus" NOT NULL DEFAULT 'DRAFT',
    "created_by_id" UUID NOT NULL,
    "approved_by_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_ui_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ui_pages" (
    "id" UUID NOT NULL,
    "project_ui_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "slug" VARCHAR(255) NOT NULL,
    "page_type" "UiPageType" NOT NULL DEFAULT 'OTHER',
    "description" TEXT,
    "url" VARCHAR(2048),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "status" "UiPageStatus" NOT NULL DEFAULT 'PLANNED',
    "is_required" BOOLEAN NOT NULL DEFAULT true,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ui_pages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ui_sections" (
    "id" UUID NOT NULL,
    "ui_page_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "section_type" "UiSectionType" NOT NULL DEFAULT 'CUSTOM',
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "status" "UiPageStatus" NOT NULL DEFAULT 'PLANNED',
    "is_required" BOOLEAN NOT NULL DEFAULT true,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ui_sections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ui_task_links" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "ui_page_id" UUID NOT NULL,
    "ui_section_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ui_task_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ui_daily_status" (
    "id" UUID NOT NULL,
    "project_ui_id" UUID NOT NULL,
    "status_date" DATE NOT NULL,
    "status" "UiStatus" NOT NULL DEFAULT 'IN_PROGRESS',
    "summary" TEXT NOT NULL,
    "blockers" TEXT,
    "completion_percentage" INTEGER,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ui_daily_status_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ui_design_links" (
    "id" UUID NOT NULL,
    "project_ui_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "url" VARCHAR(2048) NOT NULL,
    "link_type" "UiDesignLinkType" NOT NULL DEFAULT 'OTHER',
    "description" TEXT,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "ui_design_links_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "project_ui_status_created_at_idx" ON "project_ui"("status", "created_at");

-- CreateIndex
CREATE INDEX "project_ui_created_at_idx" ON "project_ui"("created_at");

-- CreateIndex
CREATE INDEX "project_ui_created_by_id_idx" ON "project_ui"("created_by_id");

-- CreateIndex
CREATE INDEX "project_ui_approved_by_id_idx" ON "project_ui"("approved_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_ui_project_id_version_number_key" ON "project_ui"("project_id", "version_number");

-- CreateIndex
CREATE INDEX "ui_pages_project_ui_id_sort_order_idx" ON "ui_pages"("project_ui_id", "sort_order");

-- CreateIndex
CREATE INDEX "ui_pages_status_idx" ON "ui_pages"("status");

-- CreateIndex
CREATE INDEX "ui_pages_page_type_idx" ON "ui_pages"("page_type");

-- CreateIndex
CREATE INDEX "ui_pages_created_by_id_idx" ON "ui_pages"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "ui_pages_project_ui_id_slug_key" ON "ui_pages"("project_ui_id", "slug");

-- CreateIndex
CREATE INDEX "ui_sections_ui_page_id_sort_order_idx" ON "ui_sections"("ui_page_id", "sort_order");

-- CreateIndex
CREATE INDEX "ui_sections_status_idx" ON "ui_sections"("status");

-- CreateIndex
CREATE INDEX "ui_sections_section_type_idx" ON "ui_sections"("section_type");

-- CreateIndex
CREATE INDEX "ui_sections_created_by_id_idx" ON "ui_sections"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "ui_sections_ui_page_id_id_key" ON "ui_sections"("ui_page_id", "id");

-- CreateIndex
CREATE INDEX "ui_task_links_ui_page_id_idx" ON "ui_task_links"("ui_page_id");

-- CreateIndex
CREATE INDEX "ui_task_links_ui_section_id_idx" ON "ui_task_links"("ui_section_id");

-- CreateIndex
CREATE UNIQUE INDEX "ui_task_links_task_id_ui_page_id_ui_section_id_key" ON "ui_task_links"("task_id", "ui_page_id", "ui_section_id");

-- CreateIndex
CREATE INDEX "ui_daily_status_status_date_idx" ON "ui_daily_status"("status_date");

-- CreateIndex
CREATE INDEX "ui_daily_status_created_by_id_idx" ON "ui_daily_status"("created_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "ui_daily_status_project_ui_id_status_date_key" ON "ui_daily_status"("project_ui_id", "status_date");

-- CreateIndex
CREATE INDEX "ui_design_links_project_ui_id_link_type_idx" ON "ui_design_links"("project_ui_id", "link_type");

-- CreateIndex
CREATE INDEX "ui_design_links_created_at_idx" ON "ui_design_links"("created_at");

-- CreateIndex
CREATE INDEX "ui_design_links_created_by_id_idx" ON "ui_design_links"("created_by_id");

-- AddForeignKey
ALTER TABLE "project_ui" ADD CONSTRAINT "project_ui_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_ui" ADD CONSTRAINT "project_ui_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_ui" ADD CONSTRAINT "project_ui_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_pages" ADD CONSTRAINT "ui_pages_project_ui_id_fkey" FOREIGN KEY ("project_ui_id") REFERENCES "project_ui"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_pages" ADD CONSTRAINT "ui_pages_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_sections" ADD CONSTRAINT "ui_sections_ui_page_id_fkey" FOREIGN KEY ("ui_page_id") REFERENCES "ui_pages"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_sections" ADD CONSTRAINT "ui_sections_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_task_links" ADD CONSTRAINT "ui_task_links_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_task_links" ADD CONSTRAINT "ui_task_links_ui_page_id_fkey" FOREIGN KEY ("ui_page_id") REFERENCES "ui_pages"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_task_links" ADD CONSTRAINT "ui_task_links_ui_page_id_ui_section_id_fkey" FOREIGN KEY ("ui_page_id", "ui_section_id") REFERENCES "ui_sections"("ui_page_id", "id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "ui_daily_status" ADD CONSTRAINT "ui_daily_status_project_ui_id_fkey" FOREIGN KEY ("project_ui_id") REFERENCES "project_ui"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_daily_status" ADD CONSTRAINT "ui_daily_status_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_design_links" ADD CONSTRAINT "ui_design_links_project_ui_id_fkey" FOREIGN KEY ("project_ui_id") REFERENCES "project_ui"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ui_design_links" ADD CONSTRAINT "ui_design_links_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Domain checks not expressible in Prisma's schema.
ALTER TABLE "project_ui" ADD CONSTRAINT "project_ui_version_positive_check"
CHECK ("version_number" > 0);

ALTER TABLE "project_ui" ADD CONSTRAINT "project_ui_approval_pair_check"
CHECK (("approved_by_id" IS NULL) = ("approved_at" IS NULL));

ALTER TABLE "ui_pages" ADD CONSTRAINT "ui_pages_sort_order_nonnegative_check"
CHECK ("sort_order" >= 0);

ALTER TABLE "ui_sections" ADD CONSTRAINT "ui_sections_sort_order_nonnegative_check"
CHECK ("sort_order" >= 0);

ALTER TABLE "ui_daily_status" ADD CONSTRAINT "ui_daily_status_percentage_range_check"
CHECK ("completion_percentage" IS NULL OR "completion_percentage" BETWEEN 0 AND 100);

-- PostgreSQL's normal nullable unique key allows repeated NULL sections.
-- Cover page-only links without coupling the common task table to UI.
CREATE UNIQUE INDEX "ui_task_links_page_only_key"
ON "ui_task_links" ("task_id", "ui_page_id")
WHERE "ui_section_id" IS NULL;

COMMIT;
