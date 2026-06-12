-- ============================================================================
-- SELEKTOR · Migración 002 — Grants, RLS y políticas
-- RLS habilitado en TODAS las tablas del schema selektor.
-- Políticas por company_id (vía users_profile/auth) + política pública mínima
-- de INSERT para postulaciones en vacantes activas.
-- Idempotente: las políticas se crean solo si no existen (DO $$ ... $$).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Grants para PostgREST (el acceso por fila lo controla RLS)
-- ---------------------------------------------------------------------------
GRANT USAGE ON SCHEMA selektor TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA selektor TO service_role;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA selektor TO authenticated;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA selektor TO anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA selektor
  GRANT SELECT, INSERT, UPDATE ON TABLES TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA selektor
  GRANT ALL ON TABLES TO service_role;

-- ---------------------------------------------------------------------------
-- Helper: empresa del usuario autenticado
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION selektor.current_company_id()
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = selektor
AS $$
  SELECT company_id FROM selektor.users_profile WHERE auth_user_id = auth.uid() LIMIT 1;
$$;

-- ---------------------------------------------------------------------------
-- Habilitar RLS en todas las tablas
-- ---------------------------------------------------------------------------
ALTER TABLE selektor.companies         ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.users_profile     ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.jobs              ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.job_questions     ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.candidates        ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.candidate_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.candidate_files   ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.email_templates   ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.email_logs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.interviews        ENABLE ROW LEVEL SECURITY;
ALTER TABLE selektor.audit_logs        ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- Políticas. Patrón idempotente: crear solo si el nombre no existe.
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  -- ========== Usuarios autenticados: acceso a los datos de SU empresa ======
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_companies_member') THEN
    CREATE POLICY selektor_companies_member ON selektor.companies
      FOR ALL TO authenticated
      USING (id = selektor.current_company_id())
      WITH CHECK (id = selektor.current_company_id());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_users_profile_self') THEN
    CREATE POLICY selektor_users_profile_self ON selektor.users_profile
      FOR ALL TO authenticated
      USING (auth_user_id = auth.uid())
      WITH CHECK (auth_user_id = auth.uid());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_jobs_member') THEN
    CREATE POLICY selektor_jobs_member ON selektor.jobs
      FOR ALL TO authenticated
      USING (company_id = selektor.current_company_id())
      WITH CHECK (company_id = selektor.current_company_id());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_job_questions_member') THEN
    CREATE POLICY selektor_job_questions_member ON selektor.job_questions
      FOR ALL TO authenticated
      USING (EXISTS (SELECT 1 FROM selektor.jobs j WHERE j.id = job_id AND j.company_id = selektor.current_company_id()))
      WITH CHECK (EXISTS (SELECT 1 FROM selektor.jobs j WHERE j.id = job_id AND j.company_id = selektor.current_company_id()));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_candidates_member') THEN
    CREATE POLICY selektor_candidates_member ON selektor.candidates
      FOR ALL TO authenticated
      USING (company_id = selektor.current_company_id())
      WITH CHECK (company_id = selektor.current_company_id());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_candidate_answers_member') THEN
    CREATE POLICY selektor_candidate_answers_member ON selektor.candidate_answers
      FOR ALL TO authenticated
      USING (EXISTS (SELECT 1 FROM selektor.candidates c WHERE c.id = candidate_id AND c.company_id = selektor.current_company_id()))
      WITH CHECK (EXISTS (SELECT 1 FROM selektor.candidates c WHERE c.id = candidate_id AND c.company_id = selektor.current_company_id()));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_candidate_files_member') THEN
    CREATE POLICY selektor_candidate_files_member ON selektor.candidate_files
      FOR ALL TO authenticated
      USING (EXISTS (SELECT 1 FROM selektor.candidates c WHERE c.id = candidate_id AND c.company_id = selektor.current_company_id()))
      WITH CHECK (EXISTS (SELECT 1 FROM selektor.candidates c WHERE c.id = candidate_id AND c.company_id = selektor.current_company_id()));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_email_templates_member') THEN
    CREATE POLICY selektor_email_templates_member ON selektor.email_templates
      FOR ALL TO authenticated
      USING (company_id = selektor.current_company_id())
      WITH CHECK (company_id = selektor.current_company_id());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_email_logs_member') THEN
    CREATE POLICY selektor_email_logs_member ON selektor.email_logs
      FOR ALL TO authenticated
      USING (company_id = selektor.current_company_id())
      WITH CHECK (company_id = selektor.current_company_id());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_interviews_member') THEN
    CREATE POLICY selektor_interviews_member ON selektor.interviews
      FOR ALL TO authenticated
      USING (company_id = selektor.current_company_id())
      WITH CHECK (company_id = selektor.current_company_id());
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_audit_logs_member') THEN
    CREATE POLICY selektor_audit_logs_member ON selektor.audit_logs
      FOR ALL TO authenticated
      USING (company_id = selektor.current_company_id())
      WITH CHECK (company_id = selektor.current_company_id());
  END IF;

  -- ========== Público (anon): lectura mínima para la página de postulación =
  -- La landing pública necesita ver la marca, las vacantes no archivadas y
  -- sus preguntas.
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_companies_public_read') THEN
    CREATE POLICY selektor_companies_public_read ON selektor.companies
      FOR SELECT TO anon USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_jobs_public_read') THEN
    CREATE POLICY selektor_jobs_public_read ON selektor.jobs
      FOR SELECT TO anon USING (status <> 'archived');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_job_questions_public_read') THEN
    CREATE POLICY selektor_job_questions_public_read ON selektor.job_questions
      FOR SELECT TO anon
      USING (EXISTS (SELECT 1 FROM selektor.jobs j WHERE j.id = job_id AND j.status <> 'archived'));
  END IF;

  -- ========== Público (anon): INSERT de postulaciones SOLO en vacantes activas
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_candidates_public_insert') THEN
    CREATE POLICY selektor_candidates_public_insert ON selektor.candidates
      FOR INSERT TO anon
      WITH CHECK (
        status = 'reviewing'
        AND EXISTS (SELECT 1 FROM selektor.jobs j
                    WHERE j.id = job_id AND j.status = 'active' AND j.company_id = company_id)
      );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_candidate_answers_public_insert') THEN
    CREATE POLICY selektor_candidate_answers_public_insert ON selektor.candidate_answers
      FOR INSERT TO anon
      WITH CHECK (
        EXISTS (SELECT 1 FROM selektor.candidates c
                JOIN selektor.jobs j ON j.id = c.job_id
                WHERE c.id = candidate_id AND j.status = 'active')
      );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_candidate_files_public_insert') THEN
    CREATE POLICY selektor_candidate_files_public_insert ON selektor.candidate_files
      FOR INSERT TO anon
      WITH CHECK (
        EXISTS (SELECT 1 FROM selektor.candidates c
                JOIN selektor.jobs j ON j.id = c.job_id
                WHERE c.id = candidate_id AND j.status = 'active')
      );
  END IF;
END $$;
