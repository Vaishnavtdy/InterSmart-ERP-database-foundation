BEGIN;

-- CreateEnum
CREATE TYPE "ScopeStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'SUPERSEDED');

-- CreateEnum
CREATE TYPE "ScopeItemType" AS ENUM ('PAGE', 'FEATURE', 'FUNCTIONALITY', 'INTEGRATION', 'CONTENT', 'DESIGN', 'DEVELOPMENT', 'MOBILE', 'OTHER');

-- CreateTable
CREATE TABLE "project_scopes" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "version_number" INTEGER NOT NULL,
    "title" VARCHAR(255),
    "summary" TEXT,
    "scope_description" TEXT,
    "status" "ScopeStatus" NOT NULL DEFAULT 'DRAFT',
    "created_by_id" UUID NOT NULL,
    "approved_by_id" UUID,
    "approved_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_scopes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_scope_items" (
    "id" UUID NOT NULL,
    "project_scope_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "item_type" "ScopeItemType" NOT NULL,
    "is_included" BOOLEAN NOT NULL DEFAULT true,
    "estimated_hours" DECIMAL(10,2),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "project_scope_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "business_analyses" (
    "id" UUID NOT NULL,
    "project_id" UUID NOT NULL,
    "purpose" TEXT,
    "about_company" TEXT,
    "target_audience" TEXT,
    "usp" TEXT,
    "conclusion" TEXT,
    "created_by_id" UUID NOT NULL,
    "updated_by_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "business_analyses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "competitors" (
    "id" UUID NOT NULL,
    "business_analysis_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "website" VARCHAR(2048),
    "description" TEXT,
    "strengths" TEXT,
    "weaknesses" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL,

    CONSTRAINT "competitors_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "project_scopes_status_created_at_idx" ON "project_scopes"("status", "created_at");

-- CreateIndex
CREATE INDEX "project_scopes_created_at_idx" ON "project_scopes"("created_at");

-- CreateIndex
CREATE INDEX "project_scopes_created_by_id_idx" ON "project_scopes"("created_by_id");

-- CreateIndex
CREATE INDEX "project_scopes_approved_by_id_idx" ON "project_scopes"("approved_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_scopes_project_id_version_number_key" ON "project_scopes"("project_id", "version_number");

-- CreateIndex
CREATE INDEX "project_scope_items_project_scope_id_sort_order_idx" ON "project_scope_items"("project_scope_id", "sort_order");

-- CreateIndex
CREATE INDEX "project_scope_items_item_type_idx" ON "project_scope_items"("item_type");

-- CreateIndex
CREATE UNIQUE INDEX "business_analyses_project_id_key" ON "business_analyses"("project_id");

-- CreateIndex
CREATE INDEX "business_analyses_created_by_id_idx" ON "business_analyses"("created_by_id");

-- CreateIndex
CREATE INDEX "business_analyses_updated_by_id_idx" ON "business_analyses"("updated_by_id");

-- CreateIndex
CREATE INDEX "competitors_business_analysis_id_idx" ON "competitors"("business_analysis_id");

-- AddForeignKey
ALTER TABLE "project_scopes" ADD CONSTRAINT "project_scopes_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_scopes" ADD CONSTRAINT "project_scopes_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_scopes" ADD CONSTRAINT "project_scopes_approved_by_id_fkey" FOREIGN KEY ("approved_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_scope_items" ADD CONSTRAINT "project_scope_items_project_scope_id_fkey" FOREIGN KEY ("project_scope_id") REFERENCES "project_scopes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_analyses" ADD CONSTRAINT "business_analyses_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_analyses" ADD CONSTRAINT "business_analyses_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "business_analyses" ADD CONSTRAINT "business_analyses_updated_by_id_fkey" FOREIGN KEY ("updated_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "competitors" ADD CONSTRAINT "competitors_business_analysis_id_fkey" FOREIGN KEY ("business_analysis_id") REFERENCES "business_analyses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Version identity and approval provenance.
ALTER TABLE "project_scopes" ADD CONSTRAINT "project_scopes_version_number_positive_check"
CHECK ("version_number" > 0);

ALTER TABLE "project_scopes" ADD CONSTRAINT "project_scopes_approval_pair_check"
CHECK (
    ("approved_by_id" IS NULL AND "approved_at" IS NULL)
    OR ("approved_by_id" IS NOT NULL AND "approved_at" IS NOT NULL)
);

ALTER TABLE "project_scopes" ADD CONSTRAINT "project_scopes_approved_metadata_check"
CHECK (
    "status" <> 'APPROVED'
    OR ("approved_by_id" IS NOT NULL AND "approved_at" IS NOT NULL)
);

CREATE UNIQUE INDEX "project_scopes_one_approved_per_project_key"
ON "project_scopes"("project_id") WHERE "status" = 'APPROVED';

ALTER TABLE "project_scope_items" ADD CONSTRAINT "project_scope_items_hours_nonnegative_check"
CHECK (
    "estimated_hours" IS NULL
    OR ("estimated_hours" >= 0 AND "estimated_hours" <> 'NaN'::numeric)
);

ALTER TABLE "project_scope_items" ADD CONSTRAINT "project_scope_items_sort_order_nonnegative_check"
CHECK ("sort_order" >= 0);

-- Approval permanently seals content/provenance, but allows later supersession.
CREATE FUNCTION "preserve_approved_project_scope"()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF OLD."approved_at" IS NOT NULL THEN
        IF TG_OP = 'DELETE' THEN
            RAISE EXCEPTION 'Previously approved project scopes cannot be deleted'
            USING ERRCODE = '23514';
        END IF;
        IF ROW(
            NEW."id", NEW."project_id", NEW."version_number", NEW."title",
            NEW."summary", NEW."scope_description", NEW."created_by_id",
            NEW."approved_by_id", NEW."approved_at", NEW."created_at"
        ) IS DISTINCT FROM ROW(
            OLD."id", OLD."project_id", OLD."version_number", OLD."title",
            OLD."summary", OLD."scope_description", OLD."created_by_id",
            OLD."approved_by_id", OLD."approved_at", OLD."created_at"
        ) THEN
            RAISE EXCEPTION 'Previously approved project scope content and provenance are immutable'
            USING ERRCODE = '23514';
        END IF;
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER "project_scopes_preserve_approved"
BEFORE UPDATE OR DELETE ON "project_scopes"
FOR EACH ROW EXECUTE FUNCTION "preserve_approved_project_scope"();

-- Lock scope parents to serialize item mutation with approval, including moves.
CREATE FUNCTION "preserve_approved_project_scope_items"()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
DECLARE
    old_scope_id uuid;
    new_scope_id uuid;
    scope_parent record;
BEGIN
    IF TG_OP <> 'INSERT' THEN
        old_scope_id := OLD."project_scope_id";
    END IF;
    IF TG_OP <> 'DELETE' THEN
        new_scope_id := NEW."project_scope_id";
    END IF;
    FOR scope_parent IN
        SELECT "id", "approved_at" FROM "project_scopes"
        WHERE "id" = old_scope_id OR "id" = new_scope_id
        ORDER BY "id" FOR UPDATE
    LOOP
        IF scope_parent."approved_at" IS NOT NULL THEN
            RAISE EXCEPTION 'Items of a previously approved project scope are immutable'
            USING ERRCODE = '23514';
        END IF;
    END LOOP;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER "project_scope_items_preserve_approved"
BEFORE INSERT OR UPDATE OR DELETE ON "project_scope_items"
FOR EACH ROW EXECUTE FUNCTION "preserve_approved_project_scope_items"();

COMMIT;
