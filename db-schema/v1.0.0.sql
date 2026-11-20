-- Glass Squid MVP baseline. Authority: business-logic-v1.1.md (not the proposal).
-- Run as the Supabase project database owner. Safe to replay this exact baseline;
-- CREATE IF NOT EXISTS is not drift repair. Subsequent changes get new migrations.
-- All relationships use UUIDs. Identity bigint IDs are internal indexes only.
-- No physical foreign keys: offline/partial datasets use logical UUID references.
-- Financial writes are online and validated by triggers; import parents first.
-- Flask uses a trusted PostgreSQL transaction (or a future transactional RPC):
-- BEGIN; SELECT set_config('glass_squid.actor_uuid', '<account uuid>', true);
-- ... mutations ...; COMMIT;
-- Derive actor from a verified Google/Supabase session, NEVER from request input.
-- Separate PostgREST requests cannot share this transaction-local context.
-- Bootstrap the first admin as database owner with actor unset. Never expose the
-- service key or raw tables to clients. Flask scopes and redacts every response.

BEGIN;
SELECT pg_advisory_xact_lock(731940, 10000);

CREATE SCHEMA IF NOT EXISTS gs_private;
REVOKE ALL ON SCHEMA gs_private FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA gs_private TO service_role;

DO $$ BEGIN
  CREATE TYPE public.gs_membership_role AS ENUM ('officer', 'member');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE public.gs_category_type AS ENUM ('income', 'expense');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE public.gs_transaction_status AS ENUM ('pending', 'verified', 'rejected', 'voided');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE public.gs_payment_method AS ENUM ('cash', 'digital');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS public.account (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  auth_user_uuid uuid UNIQUE, -- auth.users UUID; nullable before first login
  school_email text NOT NULL CHECK (school_email = lower(btrim(school_email)) AND school_email LIKE '%@%'),
  display_name text NOT NULL CHECK (btrim(display_name) <> ''),
  is_admin boolean NOT NULL DEFAULT false,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  UNIQUE (school_email) -- identity is never recycled, including archived accounts
);

CREATE TABLE IF NOT EXISTS public.setting (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  feature text NOT NULL,
  name text NOT NULL,
  value jsonb NOT NULL,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS setting_live_key ON public.setting (feature, name) WHERE archived_at IS NULL;
-- Fail closed until the school domain(s) are configured by an admin.
INSERT INTO public.setting (feature, name, value)
SELECT 'auth', 'allowed_school_email_domains', '[]'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM public.setting WHERE feature = 'auth' AND name = 'allowed_school_email_domains' AND archived_at IS NULL);

CREATE TABLE IF NOT EXISTS public.organization (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  name text NOT NULL CHECK (btrim(name) <> ''),
  description text,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);
CREATE TABLE IF NOT EXISTS public.membership (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  organization_uuid uuid NOT NULL,
  account_uuid uuid NOT NULL,
  role public.gs_membership_role NOT NULL DEFAULT 'member',
  is_active boolean NOT NULL DEFAULT true,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS membership_live_pair ON public.membership (organization_uuid, account_uuid) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS membership_account ON public.membership (account_uuid, organization_uuid);

CREATE TABLE IF NOT EXISTS public.category (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  organization_uuid uuid NOT NULL,
  name text NOT NULL CHECK (btrim(name) <> ''),
  type public.gs_category_type NOT NULL,
  allocated_centavos bigint,
  is_system_fines boolean NOT NULL DEFAULT false,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz,
  CHECK ((type = 'income' AND allocated_centavos IS NULL) OR (type = 'expense' AND allocated_centavos >= 0 AND allocated_centavos IS NOT NULL)),
  CHECK (NOT is_system_fines OR (type = 'income' AND name = 'Fines' AND archived_at IS NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS category_live_name ON public.category (organization_uuid, lower(name)) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS category_system_fines ON public.category (organization_uuid) WHERE is_system_fines;

CREATE TABLE IF NOT EXISTS public.fine_type (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  organization_uuid uuid NOT NULL,
  name text NOT NULL CHECK (btrim(name) <> ''),
  default_amount_centavos bigint NOT NULL CHECK (default_amount_centavos > 0),
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS fine_type_live_name ON public.fine_type (organization_uuid, lower(name)) WHERE archived_at IS NULL;

CREATE TABLE IF NOT EXISTS public.fine (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  organization_uuid uuid NOT NULL,
  account_uuid uuid NOT NULL,
  fine_type_uuid uuid NOT NULL,
  issued_on date NOT NULL,
  reason text NOT NULL CHECK (btrim(reason) <> ''),
  amount_centavos bigint NOT NULL CHECK (amount_centavos > 0),
  adjusted_by uuid,
  adjusted_at timestamptz,
  adjustment_reason text,
  waived_by uuid,
  waived_at timestamptz,
  waiver_reason text,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz CHECK (archived_at IS NULL),
  CHECK ((waived_at IS NULL AND waived_by IS NULL AND waiver_reason IS NULL) OR
    (waived_at IS NOT NULL AND waived_by IS NOT NULL AND waived_by <> account_uuid AND length(btrim(waiver_reason)) > 0 AND waiver_reason IS NOT NULL)),
  CHECK ((adjusted_at IS NULL AND adjusted_by IS NULL AND adjustment_reason IS NULL) OR
    (adjusted_at IS NOT NULL AND adjusted_by IS NOT NULL AND adjustment_reason IS NOT NULL AND length(btrim(adjustment_reason)) > 0))
);
CREATE INDEX IF NOT EXISTS fine_student ON public.fine (account_uuid, organization_uuid);
CREATE INDEX IF NOT EXISTS fine_type_lookup ON public.fine (fine_type_uuid);

-- A fine payment IS an income transaction, not a second copy of the money.
-- Sensitive data is never in description for fine payments; use the private table.
CREATE TABLE IF NOT EXISTS public.financial_transaction (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  organization_uuid uuid NOT NULL,
  category_uuid uuid NOT NULL,
  fine_uuid uuid,
  transaction_on date NOT NULL,
  amount_centavos bigint NOT NULL CHECK (amount_centavos > 0),
  description text NOT NULL CHECK (btrim(description) <> ''),
  status public.gs_transaction_status NOT NULL DEFAULT 'pending',
  payment_method public.gs_payment_method,
  reviewed_by uuid,
  reviewed_at timestamptz,
  rejection_reason text,
  voided_by uuid,
  voided_at timestamptz,
  void_reason text,
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz CHECK (archived_at IS NULL),
  CHECK (fine_uuid IS NULL OR (payment_method IS NOT NULL AND description = 'Fine payment')),
  CHECK (reviewed_by IS NULL OR reviewed_by <> created_by),
  CHECK ((reviewed_by IS NULL) = (reviewed_at IS NULL)),
  CHECK (status NOT IN ('verified','rejected') OR reviewed_by IS NOT NULL),
  CHECK (status <> 'pending' OR (reviewed_by IS NULL AND rejection_reason IS NULL)),
  CHECK (status <> 'rejected' OR (rejection_reason IS NOT NULL AND btrim(rejection_reason) <> '')),
  CHECK ((status = 'voided' AND voided_by IS NOT NULL AND voided_at IS NOT NULL AND void_reason IS NOT NULL AND btrim(void_reason) <> '') OR
    (status <> 'voided' AND voided_by IS NULL AND voided_at IS NULL AND void_reason IS NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS transaction_one_effective_fine_payment ON public.financial_transaction (fine_uuid)
  WHERE fine_uuid IS NOT NULL AND status IN ('pending','verified');
CREATE INDEX IF NOT EXISTS transaction_fine_history ON public.financial_transaction (fine_uuid);
CREATE INDEX IF NOT EXISTS transaction_category ON public.financial_transaction (category_uuid);
CREATE INDEX IF NOT EXISTS transaction_queue ON public.financial_transaction (organization_uuid, status, transaction_on, uuid);

CREATE TABLE IF NOT EXISTS public.transaction_private (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  organization_uuid uuid NOT NULL,
  transaction_uuid uuid NOT NULL UNIQUE,
  payee_or_source text NOT NULL CHECK (btrim(payee_or_source) <> ''),
  reference_number text CHECK (reference_number IS NULL OR btrim(reference_number) <> ''),
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz CHECK (archived_at IS NULL)
);
CREATE TABLE IF NOT EXISTS public.receipt (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  organization_uuid uuid NOT NULL,
  transaction_uuid uuid NOT NULL,
  bucket_name text NOT NULL DEFAULT 'gs-receipts' CHECK (bucket_name = 'gs-receipts'),
  object_path text NOT NULL UNIQUE CHECK (btrim(object_path) <> ''),
  original_filename text NOT NULL,
  mime_type text NOT NULL CHECK (mime_type IN ('image/jpeg','image/png','application/pdf')),
  size_bytes bigint NOT NULL CHECK (size_bytes BETWEEN 1 AND 5242880),
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  archived_at timestamptz
);
CREATE INDEX IF NOT EXISTS receipt_transaction ON public.receipt (transaction_uuid);

CREATE TABLE IF NOT EXISTS public.audit_event (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  uuid uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  organization_uuid uuid, -- NULL for system-wide admin actions; admin-only read
  entity_uuid uuid NOT NULL,
  entity_type text NOT NULL,
  action text NOT NULL,
  actor_uuid uuid,
  fine_uuid uuid, -- privacy classification, never expose to unrelated members
  occurred_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  old_data jsonb,
  new_data jsonb
);
CREATE INDEX IF NOT EXISTS audit_org_time ON public.audit_event (organization_uuid, occurred_at, uuid);
CREATE INDEX IF NOT EXISTS audit_entity ON public.audit_event (entity_uuid);
CREATE INDEX IF NOT EXISTS audit_fine ON public.audit_event (fine_uuid);

CREATE OR REPLACE FUNCTION gs_private.actor() RETURNS uuid
LANGUAGE sql STABLE SET search_path = '' AS $$
  SELECT nullif(current_setting('glass_squid.actor_uuid', true), '')::uuid
$$;

-- Central write authorization, attribution, immutable identity and soft deletion.
CREATE OR REPLACE FUNCTION gs_private.guard_write() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE a uuid := gs_private.actor(); j jsonb := to_jsonb(NEW); org uuid; admin_user boolean;
BEGIN
  IF TG_OP = 'DELETE' THEN RAISE EXCEPTION 'Hard deletion is prohibited; archive, deactivate, void or waive'; END IF;
  -- Only the project owner may perform initial/bootstrap maintenance without actor.
  IF a IS NULL AND current_user NOT IN ('postgres', 'supabase_admin') THEN
    RAISE EXCEPTION 'Authenticated server actor context required';
  END IF;
  IF a IS NOT NULL THEN
    SELECT is_admin INTO admin_user FROM public.account WHERE uuid = a AND archived_at IS NULL;
    IF admin_user IS NULL THEN RAISE EXCEPTION 'Unknown or inactive actor'; END IF;
    IF TG_TABLE_NAME IN ('account','organization','membership','setting') THEN
      IF NOT admin_user THEN RAISE EXCEPTION 'System admin required'; END IF;
    ELSIF NOT (TG_TABLE_NAME = 'category' AND TG_OP = 'INSERT' AND coalesce((j->>'is_system_fines')::boolean, false) AND pg_trigger_depth() > 1) THEN
      org := (j->>'organization_uuid')::uuid;
      IF admin_user OR NOT EXISTS (
        SELECT 1 FROM public.membership m JOIN public.organization o ON o.uuid = m.organization_uuid
        WHERE m.organization_uuid = org AND m.account_uuid = a AND m.role = 'officer'
          AND m.is_active AND m.archived_at IS NULL AND o.archived_at IS NULL
      ) THEN RAISE EXCEPTION 'Active officer required; admins cannot enter financial data'; END IF;
    END IF;
  END IF;
  IF TG_OP = 'INSERT' THEN
    NEW.created_by := a;
  ELSE
    IF NEW.uuid <> OLD.uuid OR NEW.id <> OLD.id OR NEW.created_by IS DISTINCT FROM OLD.created_by
       OR NEW.created_at <> OLD.created_at OR j->>'organization_uuid' IS DISTINCT FROM to_jsonb(OLD)->>'organization_uuid' THEN
      RAISE EXCEPTION 'Identity, organization and creation attribution are immutable';
    END IF;
  END IF;
  NEW.updated_at := clock_timestamp(); -- MVP online writes; future sync must use explicit LWW
  RETURN NEW;
END $$;

CREATE OR REPLACE FUNCTION gs_private.validate_finance() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE c public.category; f public.fine; t public.financial_transaction;
  ft public.fine_type; a uuid := gs_private.actor(); rejection text := to_jsonb(NEW)->>'rejection_reason';
BEGIN
  IF TG_TABLE_NAME = 'category' THEN
    IF TG_OP = 'UPDATE' THEN
      IF OLD.is_system_fines THEN RAISE EXCEPTION 'The Fines category is immutable'; END IF;
      IF NEW.type <> OLD.type AND EXISTS (SELECT 1 FROM public.financial_transaction WHERE category_uuid = OLD.uuid) THEN
        RAISE EXCEPTION 'A used category cannot change type';
      END IF;
      IF NEW.is_system_fines THEN RAISE EXCEPTION 'Cannot convert category to system Fines'; END IF;
    ELSIF NEW.is_system_fines AND pg_trigger_depth() < 2 THEN
      RAISE EXCEPTION 'Fines category is created by the organization trigger';
    END IF;
  ELSIF TG_TABLE_NAME = 'fine' THEN
    IF TG_OP = 'INSERT' THEN
      SELECT * INTO ft FROM public.fine_type WHERE uuid = NEW.fine_type_uuid AND organization_uuid = NEW.organization_uuid AND archived_at IS NULL;
      IF NOT FOUND OR NEW.amount_centavos <> ft.default_amount_centavos THEN RAISE EXCEPTION 'Fine must start at the fine type default'; END IF;
      IF NOT EXISTS (SELECT 1 FROM public.membership WHERE organization_uuid = NEW.organization_uuid AND account_uuid = NEW.account_uuid AND is_active AND archived_at IS NULL) THEN
        RAISE EXCEPTION 'Fine recipient must be an active member';
      END IF;
      IF NEW.waived_at IS NOT NULL OR NEW.adjusted_at IS NOT NULL THEN RAISE EXCEPTION 'New fine must be unpaid and unadjusted'; END IF;
    ELSE
      IF (NEW.account_uuid, NEW.fine_type_uuid, NEW.issued_on, NEW.reason) IS DISTINCT FROM (OLD.account_uuid, OLD.fine_type_uuid, OLD.issued_on, OLD.reason) OR OLD.waived_at IS NOT NULL THEN
        RAISE EXCEPTION 'Issued fine details are immutable; waive mistakes';
      END IF;
      IF NEW.amount_centavos <> OLD.amount_centavos THEN
        IF EXISTS (SELECT 1 FROM public.financial_transaction WHERE fine_uuid = OLD.uuid) THEN RAISE EXCEPTION 'Cannot adjust a fine with payment history'; END IF;
        IF NEW.adjustment_reason IS NULL OR btrim(NEW.adjustment_reason) = '' THEN RAISE EXCEPTION 'Adjustment reason required'; END IF;
        NEW.adjusted_by := a; NEW.adjusted_at := clock_timestamp();
      ELSE
        NEW.adjusted_by := OLD.adjusted_by; NEW.adjusted_at := OLD.adjusted_at; NEW.adjustment_reason := OLD.adjustment_reason;
      END IF;
      IF NEW.waived_at IS NOT NULL THEN
        IF a = NEW.account_uuid OR EXISTS (SELECT 1 FROM public.financial_transaction WHERE fine_uuid = OLD.uuid AND status IN ('pending','verified')) THEN
          RAISE EXCEPTION 'Cannot waive own fine or a fine with an effective payment';
        END IF;
        NEW.waived_by := a; NEW.waived_at := clock_timestamp();
      END IF;
    END IF;
  ELSIF TG_TABLE_NAME = 'financial_transaction' THEN
    SELECT * INTO c FROM public.category WHERE uuid = NEW.category_uuid AND organization_uuid = NEW.organization_uuid FOR SHARE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Category must belong to organization'; END IF;
    IF TG_OP = 'INSERT' THEN
      IF c.archived_at IS NOT NULL OR NEW.status <> 'pending' THEN RAISE EXCEPTION 'New transaction needs live category and pending status'; END IF;
      NEW.reviewed_by := NULL; NEW.reviewed_at := NULL;
    ELSE
      IF (NEW.category_uuid, NEW.fine_uuid, NEW.transaction_on, NEW.amount_centavos, NEW.description, NEW.payment_method) IS DISTINCT FROM
         (OLD.category_uuid, OLD.fine_uuid, OLD.transaction_on, OLD.amount_centavos, OLD.description, OLD.payment_method) THEN
        RAISE EXCEPTION 'Financial facts are immutable; void and record a replacement';
      END IF;
      IF NOT ((OLD.status = 'pending' AND NEW.status IN ('verified','rejected','voided')) OR
              (OLD.status = 'verified' AND NEW.status = 'voided')) THEN RAISE EXCEPTION 'Invalid transaction state transition'; END IF;
      NEW.reviewed_by := OLD.reviewed_by; NEW.reviewed_at := OLD.reviewed_at; NEW.rejection_reason := OLD.rejection_reason;
      IF NEW.status IN ('verified','rejected') THEN
        IF a = OLD.created_by THEN RAISE EXCEPTION 'A different officer must review'; END IF;
        NEW.reviewed_by := a; NEW.reviewed_at := clock_timestamp();
        IF NEW.status = 'rejected' THEN NEW.rejection_reason := nullif(btrim(rejection), ''); END IF;
      END IF;
      IF NEW.status = 'voided' THEN NEW.voided_by := a; NEW.voided_at := clock_timestamp(); END IF;
    END IF;
    IF c.is_system_fines <> (NEW.fine_uuid IS NOT NULL) THEN RAISE EXCEPTION 'Fines category requires a fine payment and vice versa'; END IF;
    IF NEW.fine_uuid IS NOT NULL THEN
      -- Serializes payment creation with fine adjustments/waivers and other payments.
      SELECT * INTO f FROM public.fine WHERE uuid = NEW.fine_uuid FOR UPDATE;
      IF NOT FOUND OR f.organization_uuid <> NEW.organization_uuid OR f.amount_centavos <> NEW.amount_centavos OR f.waived_at IS NOT NULL THEN
        RAISE EXCEPTION 'Payment must match an unwaived fine in this organization for its full amount';
      END IF;
    END IF;
  ELSIF TG_TABLE_NAME IN ('receipt','transaction_private') THEN
    SELECT * INTO t FROM public.financial_transaction WHERE uuid = NEW.transaction_uuid FOR UPDATE;
    IF NOT FOUND OR t.organization_uuid <> NEW.organization_uuid THEN RAISE EXCEPTION 'Transaction must belong to organization'; END IF;
    IF t.status <> 'pending' THEN RAISE EXCEPTION 'Supporting data is frozen after review or void'; END IF;
    IF TG_OP = 'UPDATE' AND NEW.transaction_uuid <> OLD.transaction_uuid THEN RAISE EXCEPTION 'Cannot move supporting data'; END IF;
    IF TG_TABLE_NAME = 'receipt' THEN
      IF NEW.object_path NOT LIKE NEW.organization_uuid::text || '/' || NEW.transaction_uuid::text || '/%' THEN
        RAISE EXCEPTION 'Receipt path must start organization_uuid/transaction_uuid/';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END $$;

-- Deferred validation permits transaction + private details + receipt in one commit.
CREATE OR REPLACE FUNCTION gs_private.complete_transaction() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
DECLARE t public.financial_transaction; c public.category; target uuid;
BEGIN
  target := CASE WHEN TG_TABLE_NAME = 'financial_transaction' THEN NEW.uuid ELSE (to_jsonb(NEW)->>'transaction_uuid')::uuid END;
  SELECT * INTO t FROM public.financial_transaction WHERE uuid = target;
  SELECT * INTO c FROM public.category WHERE uuid = t.category_uuid;
  IF NOT EXISTS (SELECT 1 FROM public.transaction_private WHERE transaction_uuid = target AND organization_uuid = t.organization_uuid) THEN
    RAISE EXCEPTION 'Payee/source details required';
  END IF;
  IF c.type = 'expense' AND NOT EXISTS (SELECT 1 FROM public.receipt WHERE transaction_uuid = target AND archived_at IS NULL) THEN
    RAISE EXCEPTION 'Expense receipt required';
  END IF;
  IF t.fine_uuid IS NOT NULL AND t.payment_method = 'digital' AND
    NOT EXISTS (SELECT 1 FROM public.transaction_private WHERE transaction_uuid = target AND reference_number IS NOT NULL) AND
    NOT EXISTS (SELECT 1 FROM public.receipt WHERE transaction_uuid = target AND archived_at IS NULL) THEN
    RAISE EXCEPTION 'Digital fine payment requires reference number or proof';
  END IF;
  RETURN NULL;
END $$;

CREATE OR REPLACE FUNCTION gs_private.seed_fines_category() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  INSERT INTO public.category (organization_uuid, name, type, is_system_fines, created_by)
  VALUES (NEW.uuid, 'Fines', 'income', true, NEW.created_by);
  RETURN NULL;
END $$;

CREATE OR REPLACE FUNCTION gs_private.append_audit() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE j jsonb := to_jsonb(NEW); before_row jsonb; fine_ref uuid;
BEGIN
  IF TG_OP = 'UPDATE' THEN before_row := to_jsonb(OLD); END IF;
  fine_ref := CASE WHEN TG_TABLE_NAME = 'fine' THEN NEW.uuid ELSE (j->>'fine_uuid')::uuid END;
  IF TG_TABLE_NAME IN ('receipt','transaction_private') THEN
    SELECT fine_uuid INTO fine_ref FROM public.financial_transaction WHERE uuid = (j->>'transaction_uuid')::uuid;
  END IF;
  INSERT INTO public.audit_event (organization_uuid, entity_uuid, entity_type, action, actor_uuid, fine_uuid, old_data, new_data)
  VALUES (CASE WHEN TG_TABLE_NAME = 'organization' THEN NEW.uuid ELSE (j->>'organization_uuid')::uuid END,
    NEW.uuid, TG_TABLE_NAME, CASE WHEN TG_OP = 'INSERT' THEN 'created'
      WHEN TG_TABLE_NAME = 'financial_transaction' THEN j->>'status'
      WHEN TG_TABLE_NAME = 'fine' AND j->>'waived_at' IS NOT NULL THEN 'waived' ELSE 'updated' END,
    gs_private.actor(), fine_ref, before_row - 'id', j - 'id');
  RETURN NULL;
END $$;
CREATE OR REPLACE FUNCTION gs_private.reject_audit_mutation() RETURNS trigger
LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN RAISE EXCEPTION 'History is append-only'; END $$;

-- Alphabetical BEFORE trigger order: attribution/authorization before validation.
DO $$ DECLARE tbl text; BEGIN
  FOREACH tbl IN ARRAY ARRAY['account','setting','organization','membership','category','fine_type','fine','financial_transaction','transaction_private','receipt'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS a_guard ON public.%I', tbl);
    EXECUTE format('CREATE TRIGGER a_guard BEFORE INSERT OR UPDATE OR DELETE ON public.%I FOR EACH ROW EXECUTE FUNCTION gs_private.guard_write()', tbl);
    EXECUTE format('DROP TRIGGER IF EXISTS z_audit ON public.%I', tbl);
    EXECUTE format('CREATE TRIGGER z_audit AFTER INSERT OR UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION gs_private.append_audit()', tbl);
  END LOOP;
  FOREACH tbl IN ARRAY ARRAY['category','fine','financial_transaction','transaction_private','receipt'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS b_validate ON public.%I', tbl);
    EXECUTE format('CREATE TRIGGER b_validate BEFORE INSERT OR UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION gs_private.validate_finance()', tbl);
  END LOOP;
  FOREACH tbl IN ARRAY ARRAY['financial_transaction','transaction_private','receipt'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS transaction_complete ON public.%I', tbl);
    EXECUTE format('CREATE CONSTRAINT TRIGGER transaction_complete AFTER INSERT OR UPDATE ON public.%I DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION gs_private.complete_transaction()', tbl);
  END LOOP;
END $$;
DROP TRIGGER IF EXISTS seed_fines ON public.organization;
CREATE TRIGGER seed_fines AFTER INSERT ON public.organization FOR EACH ROW EXECUTE FUNCTION gs_private.seed_fines_category();
DROP TRIGGER IF EXISTS audit_immutable ON public.audit_event;
CREATE TRIGGER audit_immutable BEFORE UPDATE OR DELETE OR TRUNCATE ON public.audit_event FOR EACH STATEMENT EXECUTE FUNCTION gs_private.reject_audit_mutation();

-- No stored fine status to drift: rejected/voided payments automatically reopen it.
CREATE OR REPLACE VIEW public.fine_state WITH (security_invoker = true) AS
SELECT f.uuid, f.organization_uuid, f.account_uuid, f.amount_centavos,
  CASE WHEN f.waived_at IS NOT NULL THEN 'waived' WHEN t.status = 'verified' THEN 'paid'
       WHEN t.status = 'pending' THEN 'payment_pending' ELSE 'unpaid' END AS status
FROM public.fine f LEFT JOIN public.financial_transaction t ON t.fine_uuid = f.uuid AND t.status IN ('pending','verified');

CREATE OR REPLACE VIEW public.category_budget WITH (security_invoker = true) AS
SELECT c.uuid AS category_uuid, c.organization_uuid, c.name, c.allocated_centavos,
  coalesce(sum(t.amount_centavos) FILTER (WHERE t.status = 'verified'), 0) AS spent_centavos,
  c.allocated_centavos - coalesce(sum(t.amount_centavos) FILTER (WHERE t.status = 'verified'), 0) AS remaining_centavos,
  c.archived_at
FROM public.category c LEFT JOIN public.financial_transaction t ON t.category_uuid = c.uuid AND t.organization_uuid = c.organization_uuid
WHERE c.type = 'expense' GROUP BY c.uuid, c.organization_uuid, c.name, c.allocated_centavos, c.archived_at;

CREATE OR REPLACE VIEW public.organization_dashboard WITH (security_invoker = true) AS
SELECT o.uuid AS organization_uuid, b.total_budget_centavos, x.verified_income_centavos,
  x.verified_expenses_centavos, x.verified_income_centavos - x.verified_expenses_centavos AS fund_balance_centavos,
  b.total_budget_centavos - x.verified_expenses_centavos AS remaining_budget_centavos,
  x.pending_centavos, x.fines_collected_centavos, f.fines_outstanding_centavos
FROM public.organization o
CROSS JOIN LATERAL (SELECT coalesce(sum(allocated_centavos),0) AS total_budget_centavos FROM public.category
  WHERE organization_uuid = o.uuid AND type = 'expense' AND archived_at IS NULL) b
CROSS JOIN LATERAL (SELECT
  coalesce(sum(t.amount_centavos) FILTER (WHERE t.status = 'verified' AND c.type = 'income'),0) AS verified_income_centavos,
  coalesce(sum(t.amount_centavos) FILTER (WHERE t.status = 'verified' AND c.type = 'expense'),0) AS verified_expenses_centavos,
  coalesce(sum(t.amount_centavos) FILTER (WHERE t.status = 'pending'),0) AS pending_centavos,
  coalesce(sum(t.amount_centavos) FILTER (WHERE t.status = 'verified' AND t.fine_uuid IS NOT NULL),0) AS fines_collected_centavos
  FROM public.financial_transaction t JOIN public.category c ON c.uuid = t.category_uuid AND c.organization_uuid = t.organization_uuid
  WHERE t.organization_uuid = o.uuid) x
CROSS JOIN LATERAL (SELECT coalesce(sum(amount_centavos),0) AS fines_outstanding_centavos
  FROM public.fine_state WHERE organization_uuid = o.uuid AND status IN ('unpaid','payment_pending')) f
WHERE o.archived_at IS NULL;

-- Defense in depth: no browser table policies. Flask service role bypasses RLS.
-- Restrict grants to these application objects; never change unrelated schemas.
DO $$ DECLARE tbl text; BEGIN
  FOREACH tbl IN ARRAY ARRAY['account','setting','organization','membership','category','fine_type','fine','financial_transaction','transaction_private','receipt','audit_event'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tbl);
    EXECUTE format('REVOKE ALL ON public.%I FROM PUBLIC, anon, authenticated, service_role', tbl);
    EXECUTE format('GRANT SELECT ON public.%I TO service_role', tbl);
    IF tbl <> 'audit_event' THEN
      EXECUTE format('GRANT INSERT, UPDATE ON public.%I TO service_role', tbl);
    END IF;
    EXECUTE format('REVOKE ALL ON SEQUENCE public.%I FROM PUBLIC, anon, authenticated', tbl || '_id_seq');
    EXECUTE format('GRANT USAGE, SELECT ON SEQUENCE public.%I TO service_role', tbl || '_id_seq');
    IF tbl NOT IN ('account','setting','organization','audit_event') THEN
      EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON public.%I (organization_uuid, updated_at, uuid)', tbl || '_org_changes', tbl);
    END IF;
  END LOOP;
  FOREACH tbl IN ARRAY ARRAY['fine_state','category_budget','organization_dashboard'] LOOP
    EXECUTE format('REVOKE ALL ON public.%I FROM PUBLIC, anon, authenticated', tbl);
    EXECUTE format('GRANT SELECT ON public.%I TO service_role', tbl);
  END LOOP;
END $$;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA gs_private FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA gs_private TO service_role;

-- Provision private bucket through Supabase Storage API (not storage table DML):
-- name/id: gs-receipts; public: false; file_size_limit: 5242880;
-- allowed_mime_types: [image/jpeg, image/png, application/pdf].
-- Upload and validate actual bytes before recording metadata; issue short-lived
-- signed URLs only after org membership and fine-owner/officer checks in Flask.
COMMIT;
