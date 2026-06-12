-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║ SELEKTOR · SETUP COMPLETO (migraciones 001 → 006 consolidadas)           ║
-- ║                                                                          ║
-- ║ Proyecto Supabase compartido con "The W". Este script:                   ║
-- ║  · Crea el schema aislado "selektor" con todas sus tablas, RLS y datos.  ║
-- ║  · NO contiene DROP/TRUNCATE/DELETE/ALTER sobre objetos fuera de         ║
-- ║    "selektor". Única excepción (sección STORAGE, claramente marcada):    ║
-- ║    2 buckets NUEVOS con prefijo selektor- y 2 políticas nuevas sobre     ║
-- ║    storage.objects limitadas a esos buckets. Nada existente se modifica. ║
-- ║  · Es IDEMPOTENTE: se puede re-ejecutar completo sin error               ║
-- ║    (IF NOT EXISTS / ON CONFLICT DO NOTHING / guards en pg_policies).     ║
-- ║                                                                          ║
-- ║ Pegar COMPLETO en el SQL Editor del dashboard y ejecutar una sola vez.   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝


-- ┌──────────────────────────────────────────────────────────────────────────
-- │ SECCIÓN: 001_selektor_schema.sql
-- └──────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- SELEKTOR · Migración 001 — Schema aislado, tablas e índices
-- Proyecto compartido con "The W": NO se toca el schema public ni ningún
-- objeto existente. Todo es idempotente (IF NOT EXISTS / ON CONFLICT).
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS selektor;

-- ---------------------------------------------------------------------------
-- Empresas (multi-tenant por company_id)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.companies (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  slug        text NOT NULL UNIQUE,
  brand_color text NOT NULL DEFAULT '#F2540B',
  email       text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Perfiles de usuario (vínculo con auth.users vía uuid, sin FK para no crear
-- dependencias sobre objetos compartidos)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.users_profile (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id uuid UNIQUE,
  company_id   uuid NOT NULL REFERENCES selektor.companies(id),
  full_name    text,
  role         text NOT NULL DEFAULT 'recruiter',
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Vacantes
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.jobs (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES selektor.companies(id),
  title        text NOT NULL,
  slug         text NOT NULL,
  city         text,
  modality     text,
  contract     text,
  salary       text,
  description  text,
  requirements jsonb NOT NULL DEFAULT '[]',
  benefits     jsonb NOT NULL DEFAULT '[]',
  status       text NOT NULL DEFAULT 'active'
               CHECK (status IN ('active','paused','closed','archived')),
  created_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (company_id, slug)
);

-- ---------------------------------------------------------------------------
-- Preguntas por vacante
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.job_questions (
  id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id    uuid NOT NULL REFERENCES selektor.jobs(id) ON DELETE CASCADE,
  label     text NOT NULL,
  type      text NOT NULL DEFAULT 'short_text'
            CHECK (type IN ('short_text','long_text','yes_no')),
  required  boolean NOT NULL DEFAULT false,
  position  integer NOT NULL DEFAULT 0
);

-- ---------------------------------------------------------------------------
-- Candidatos (estados del proceso, sin cambios respecto a la app)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.candidates (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id       uuid NOT NULL REFERENCES selektor.jobs(id),
  company_id   uuid NOT NULL REFERENCES selektor.companies(id),
  name         text NOT NULL,
  doc          text,
  city         text,
  phone        text,
  email        text NOT NULL,
  last_job     text,
  years        numeric NOT NULL DEFAULT 0,
  salary       text,
  availability text,
  status       text NOT NULL DEFAULT 'reviewing'
               CHECK (status IN ('reviewing','preselected','observation',
                                 'interview_scheduled','finalist','selected','rejected')),
  notes        text NOT NULL DEFAULT '',
  applied_at   date NOT NULL DEFAULT current_date,
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Respuestas y archivos de candidatos
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.candidate_answers (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  candidate_id uuid NOT NULL REFERENCES selektor.candidates(id) ON DELETE CASCADE,
  question_id  uuid REFERENCES selektor.job_questions(id),
  answer       text
);

CREATE TABLE IF NOT EXISTS selektor.candidate_files (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  candidate_id uuid NOT NULL REFERENCES selektor.candidates(id) ON DELETE CASCADE,
  file_name    text NOT NULL,
  storage_path text,   -- selektor-candidate-documents/company_id/job_id/candidate_id/archivo
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Plantillas de correo (las 7 claves de la app)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.email_templates (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES selektor.companies(id),
  template_key text NOT NULL
               CHECK (template_key IN ('application_received','preselected','observation',
                                       'rejected','interview_invitation','selected','job_closed')),
  name         text NOT NULL,
  subject      text NOT NULL,
  body         text NOT NULL,
  UNIQUE (company_id, template_key)
);

-- ---------------------------------------------------------------------------
-- Registro de correos (envío simulado: solo se registra)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.email_logs (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES selektor.companies(id),
  candidate_id uuid REFERENCES selektor.candidates(id),
  template_key text,
  to_email     text NOT NULL,
  subject      text NOT NULL,
  body         text NOT NULL,
  sent_at      timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Entrevistas (Google Calendar sigue simulado: solo se registra)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.interviews (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   uuid NOT NULL REFERENCES selektor.companies(id),
  candidate_id uuid NOT NULL REFERENCES selektor.candidates(id),
  job_id       uuid NOT NULL REFERENCES selektor.jobs(id),
  date         date,
  start_time   text,
  end_time     text,
  modality     text,
  place        text,
  recruiter    text,
  notes        text NOT NULL DEFAULT '',
  created_at   timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Auditoría
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS selektor.audit_logs (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES selektor.companies(id),
  actor      text,
  action     text NOT NULL,
  entity     text,
  entity_id  uuid,
  payload    jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- Índices
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS selektor_jobs_company_idx        ON selektor.jobs (company_id);
CREATE INDEX IF NOT EXISTS selektor_candidates_job_idx      ON selektor.candidates (job_id);
CREATE INDEX IF NOT EXISTS selektor_candidates_company_idx  ON selektor.candidates (company_id, status);
CREATE INDEX IF NOT EXISTS selektor_answers_candidate_idx   ON selektor.candidate_answers (candidate_id);
CREATE INDEX IF NOT EXISTS selektor_files_candidate_idx     ON selektor.candidate_files (candidate_id);
CREATE INDEX IF NOT EXISTS selektor_email_logs_company_idx  ON selektor.email_logs (company_id, sent_at DESC);
CREATE INDEX IF NOT EXISTS selektor_interviews_cand_idx     ON selektor.interviews (candidate_id);

-- ┌──────────────────────────────────────────────────────────────────────────
-- │ SECCIÓN: 002_selektor_rls.sql
-- └──────────────────────────────────────────────────────────────────────────
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

-- ┌──────────────────────────────────────────────────────────────────────────
-- │ SECCIÓN: 003_selektor_demo_policies.sql
-- └──────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- SELEKTOR · Migración 003 — Políticas TEMPORALES de demo (panel sin Auth)
--
-- ⚠️ ADVERTENCIA: la app aún no integra Supabase Auth, por lo que el panel
-- interno opera con la anon key. Estas políticas dan al rol anon el acceso
-- que el panel necesita (leer candidatos, cambiar estados, registrar correos
-- y entrevistas, editar plantillas y marca, cerrar vacantes).
--
-- ⚠️ RETIRAR cuando se active Auth: todas se llaman selektor_demo_* para
-- poder eliminarlas de un golpe llegado el momento (las políticas definitivas
-- de la migración 002 quedan intactas). Solo aplican a tablas del schema
-- selektor; ningún dato de The W es alcanzable por ellas.
-- ============================================================================

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_candidates_read') THEN
    CREATE POLICY selektor_demo_candidates_read ON selektor.candidates
      FOR SELECT TO anon USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_candidates_update') THEN
    CREATE POLICY selektor_demo_candidates_update ON selektor.candidates
      FOR UPDATE TO anon USING (true) WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_answers_read') THEN
    CREATE POLICY selektor_demo_answers_read ON selektor.candidate_answers
      FOR SELECT TO anon USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_files_read') THEN
    CREATE POLICY selektor_demo_files_read ON selektor.candidate_files
      FOR SELECT TO anon USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_jobs_update') THEN
    CREATE POLICY selektor_demo_jobs_update ON selektor.jobs
      FOR UPDATE TO anon USING (true) WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_templates_read') THEN
    CREATE POLICY selektor_demo_templates_read ON selektor.email_templates
      FOR SELECT TO anon USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_templates_update') THEN
    CREATE POLICY selektor_demo_templates_update ON selektor.email_templates
      FOR UPDATE TO anon USING (true) WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_email_logs_read') THEN
    CREATE POLICY selektor_demo_email_logs_read ON selektor.email_logs
      FOR SELECT TO anon USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_email_logs_insert') THEN
    CREATE POLICY selektor_demo_email_logs_insert ON selektor.email_logs
      FOR INSERT TO anon WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_interviews_read') THEN
    CREATE POLICY selektor_demo_interviews_read ON selektor.interviews
      FOR SELECT TO anon USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_interviews_insert') THEN
    CREATE POLICY selektor_demo_interviews_insert ON selektor.interviews
      FOR INSERT TO anon WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='selektor' AND policyname='selektor_demo_companies_update') THEN
    CREATE POLICY selektor_demo_companies_update ON selektor.companies
      FOR UPDATE TO anon USING (true) WITH CHECK (true);
  END IF;
END $$;

-- Para retirar estas políticas cuando exista Auth (NO ejecutar ahora):
-- SELECT format('DROP POLICY %I ON selektor.%I;', policyname, tablename)
-- FROM pg_policies WHERE schemaname='selektor' AND policyname LIKE 'selektor_demo_%';

-- ┌──────────────────────────────────────────────────────────────────────────
-- │ SECCIÓN: 004_selektor_storage.sql
-- │ ⚠️  ÚNICA SECCIÓN QUE ESCRIBE EN EL SCHEMA COMPARTIDO storage:
-- │    - INSERT de 2 buckets nuevos (selektor-candidate-documents,
-- │      selektor-company-assets) con ON CONFLICT DO NOTHING.
-- │    - 2 CREATE POLICY nuevas sobre storage.objects, restringidas con
-- │      bucket_id a SOLO esos 2 buckets. Buckets y políticas existentes
-- │      de The W no se tocan. Si prefieres revisarla aparte, puedes
-- │      omitir esta sección y ejecutarla luego: la app no la necesita
-- │      todavía (la subida de archivos sigue simulada).
-- └──────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- SELEKTOR · Migración 004 — Buckets privados de Storage
--
-- Crea SOLO buckets nuevos (INSERT ... ON CONFLICT DO NOTHING: si ya existieran,
-- no se tocan). No modifica ningún bucket existente de The W.
-- Estructura de carpetas: company_id/job_id/candidate_id/archivo
--
-- Las políticas sobre storage.objects son ADITIVAS (CREATE POLICY nuevas,
-- prefijo selektor_) y están limitadas con bucket_id a los buckets nuevos,
-- por lo que no afectan el acceso a ningún objeto existente.
-- ============================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES
  ('selektor-candidate-documents', 'selektor-candidate-documents', false),
  ('selektor-company-assets',      'selektor-company-assets',      false)
ON CONFLICT (id) DO NOTHING;

DO $$
BEGIN
  -- Usuarios autenticados: gestión de objetos solo dentro de los buckets selektor-*
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='storage' AND policyname='selektor_objects_member_all') THEN
    CREATE POLICY selektor_objects_member_all ON storage.objects
      FOR ALL TO authenticated
      USING (bucket_id IN ('selektor-candidate-documents','selektor-company-assets'))
      WITH CHECK (bucket_id IN ('selektor-candidate-documents','selektor-company-assets'));
  END IF;

  -- Público: subir documentos de postulación (solo INSERT, solo bucket de candidatos)
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='storage' AND policyname='selektor_objects_public_upload') THEN
    CREATE POLICY selektor_objects_public_upload ON storage.objects
      FOR INSERT TO anon
      WITH CHECK (bucket_id = 'selektor-candidate-documents');
  END IF;
END $$;

-- ┌──────────────────────────────────────────────────────────────────────────
-- │ SECCIÓN: 005_selektor_seed.sql
-- └──────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- SELEKTOR · Migración 005 — Datos de prueba (seed)
-- 1 empresa, 2 vacantes (con preguntas), 3 candidatos (con respuestas y
-- archivos), 7 plantillas y 1 correo de ejemplo.
-- Idempotente: UUIDs fijos + ON CONFLICT DO NOTHING.
-- ============================================================================

-- Empresa
INSERT INTO selektor.companies (id, name, slug, brand_color, email) VALUES
  ('a0000000-0000-4000-8000-000000000001', 'PingPong Burger', 'pingpongburger', '#F2540B', 'seleccion@pingpongburger.co')
ON CONFLICT (id) DO NOTHING;

-- Vacantes
INSERT INTO selektor.jobs (id, company_id, title, slug, city, modality, contract, salary, description, requirements, benefits, status) VALUES
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
   'Cajero — Sede Laureles', 'cajero-laureles', 'Medellín', 'Presencial', 'Término fijo', '$1.500.000 – $1.800.000 COP',
   'Buscamos una persona ágil y amable para atención en caja, manejo de pedidos y cierre de turno en nuestra sede de Laureles.',
   '["Bachiller graduado","Experiencia mínima de 6 meses en atención al cliente","Disponibilidad fines de semana","Manejo básico de datáfono y caja"]',
   '["Alimentación por turno","Recargos al día","Estabilidad y buen ambiente","Posibilidad de crecimiento a líder de turno"]',
   'active'),
  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001',
   'Community Manager', 'community-manager', 'Remoto — Colombia', 'Remoto', 'Prestación de servicios', 'A convenir',
   'Gestión de redes, contenido y comunidad para nuestra marca.',
   '["Portafolio demostrable","Experiencia 1+ año en redes","Edición básica de video"]',
   '["Trabajo remoto","Horario flexible"]',
   'active')
ON CONFLICT (id) DO NOTHING;

-- Preguntas por vacante
INSERT INTO selektor.job_questions (id, job_id, label, type, required, position) VALUES
  ('c0000000-0000-4000-8000-000000000011', 'b0000000-0000-4000-8000-000000000001', '¿Por qué quieres trabajar con nosotros?',      'long_text',  true, 1),
  ('c0000000-0000-4000-8000-000000000012', 'b0000000-0000-4000-8000-000000000001', '¿Tienes disponibilidad los fines de semana?',  'yes_no',     true, 2),
  ('c0000000-0000-4000-8000-000000000013', 'b0000000-0000-4000-8000-000000000001', '¿Has trabajado antes en restaurantes?',        'yes_no',     true, 3),
  ('c0000000-0000-4000-8000-000000000021', 'b0000000-0000-4000-8000-000000000002', 'Comparte el enlace de tu mejor campaña',       'short_text', true, 1)
ON CONFLICT (id) DO NOTHING;

-- Candidatos (3)
INSERT INTO selektor.candidates (id, job_id, company_id, name, doc, city, phone, email, last_job, years, salary, availability, status, notes, applied_at) VALUES
  ('d0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
   'Mariana López Cardona', 'CC 1.020.443.221', 'Medellín', '301 552 8810', 'mariana.lopez@gmail.com',
   'Cajera — Frisby', 2, '$1.700.000', 'Inmediata', 'finalist', 'Excelente actitud en llamada de filtro.', '2026-06-02'),
  ('d0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001',
   'Julián Restrepo Mesa', 'CC 1.036.221.904', 'Medellín', '310 224 7741', 'julianrm@hotmail.com',
   'Vendedor — Éxito', 1, '$1.600.000', '15 días', 'interview_scheduled', '', '2026-06-03'),
  ('d0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001',
   'Laura Cifuentes', 'CC 1.018.477.220', 'Bogotá', '315 220 9981', 'lauracif@gmail.com',
   'CM — Agencia Pulpo', 2, '$2.800.000', 'Inmediata', 'reviewing', '', '2026-06-08')
ON CONFLICT (id) DO NOTHING;

-- Respuestas
INSERT INTO selektor.candidate_answers (id, candidate_id, question_id, answer) VALUES
  ('e0000000-0000-4000-8000-000000000011', 'd0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000011', 'Me encanta la marca y vivo cerca de la sede.'),
  ('e0000000-0000-4000-8000-000000000012', 'd0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000012', 'Sí'),
  ('e0000000-0000-4000-8000-000000000013', 'd0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000013', 'Sí'),
  ('e0000000-0000-4000-8000-000000000021', 'd0000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000011', 'Busco estabilidad y crecimiento.'),
  ('e0000000-0000-4000-8000-000000000022', 'd0000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000012', 'Sí'),
  ('e0000000-0000-4000-8000-000000000023', 'd0000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000013', 'No'),
  ('e0000000-0000-4000-8000-000000000031', 'd0000000-0000-4000-8000-000000000003', 'c0000000-0000-4000-8000-000000000021', 'instagram.com/campana-x')
ON CONFLICT (id) DO NOTHING;

-- Archivos (simulados: aún no hay subida real a Storage)
INSERT INTO selektor.candidate_files (id, candidate_id, file_name, storage_path) VALUES
  ('f0000000-0000-4000-8000-000000000011', 'd0000000-0000-4000-8000-000000000001', 'hoja-de-vida.pdf', NULL),
  ('f0000000-0000-4000-8000-000000000012', 'd0000000-0000-4000-8000-000000000001', 'cedula.pdf', NULL),
  ('f0000000-0000-4000-8000-000000000013', 'd0000000-0000-4000-8000-000000000001', 'certificado-frisby.pdf', NULL),
  ('f0000000-0000-4000-8000-000000000021', 'd0000000-0000-4000-8000-000000000002', 'hoja-de-vida.pdf', NULL),
  ('f0000000-0000-4000-8000-000000000031', 'd0000000-0000-4000-8000-000000000003', 'hoja-de-vida.pdf', NULL),
  ('f0000000-0000-4000-8000-000000000032', 'd0000000-0000-4000-8000-000000000003', 'portafolio.pdf', NULL)
ON CONFLICT (id) DO NOTHING;

-- Plantillas de correo (7)
INSERT INTO selektor.email_templates (company_id, template_key, name, subject, body) VALUES
  ('a0000000-0000-4000-8000-000000000001', 'application_received', 'Confirmación de postulación',
   'Hemos recibido tu postulación para [cargo]',
   E'Hola [nombre],\n\nGracias por postularte al cargo de [cargo] en [empresa].\n\nHemos recibido correctamente tu información y los documentos adjuntos. Nuestro equipo revisará tu perfil dentro del proceso de selección.\n\nCordialmente,\nEquipo de Selección\n[empresa]'),
  ('a0000000-0000-4000-8000-000000000001', 'preselected', 'Preseleccionado',
   'Tu perfil continúa en nuestro proceso de selección',
   E'Hola [nombre],\n\nDespués de revisar tu información, consideramos que tu perfil presenta elementos alineados con lo que buscamos para el cargo de [cargo] en [empresa]. Continuarás en el proceso de selección.\n\nCordialmente,\nEquipo de Selección\n[empresa]'),
  ('a0000000-0000-4000-8000-000000000001', 'observation', 'En observación',
   'Seguimos revisando tu postulación',
   E'Hola [nombre],\n\nTu perfil para el cargo de [cargo] en [empresa] continúa en revisión. Nuestro equipo está evaluando cuidadosamente la información recibida.\n\nCordialmente,\nEquipo de Selección\n[empresa]'),
  ('a0000000-0000-4000-8000-000000000001', 'rejected', 'No continúa',
   'Actualización sobre tu postulación',
   E'Hola [nombre],\n\nGracias por participar en el proceso para el cargo de [cargo] en [empresa]. Hemos decidido continuar con candidatos que se ajustan de manera más específica a los requerimientos actuales.\n\nTe deseamos muchos éxitos en tus próximos proyectos.\n\nCordialmente,\nEquipo de Selección\n[empresa]'),
  ('a0000000-0000-4000-8000-000000000001', 'interview_invitation', 'Invitación a entrevista',
   'Invitación a entrevista para [cargo]',
   E'Hola [nombre],\n\nQueremos avanzar contigo a una nueva etapa del proceso para el cargo de [cargo] en [empresa].\n\nFecha: [fecha_entrevista]\nHora: [hora_entrevista]\nModalidad: [modalidad]\nLugar o enlace: [ubicacion_o_link]\nResponsable: [nombre_reclutador]\n\nPor favor confirma tu asistencia.\n\nCordialmente,\nEquipo de Selección\n[empresa]'),
  ('a0000000-0000-4000-8000-000000000001', 'selected', 'Seleccionado',
   'Has sido seleccionado para el cargo de [cargo]',
   E'Hola [nombre],\n\nNos complace informarte que has sido seleccionado para el cargo de [cargo] en [empresa]. Tu perfil destacó positivamente durante el proceso.\n\nPronto te contactaremos para coordinar la etapa de vinculación.\n\nFelicitaciones.\n\nCordialmente,\nEquipo de Selección\n[empresa]'),
  ('a0000000-0000-4000-8000-000000000001', 'job_closed', 'Cierre de vacante',
   'Cierre del proceso de selección para [cargo]',
   E'Hola [nombre],\n\nGracias por participar en el proceso para el cargo de [cargo] en [empresa]. La vacante ha sido cubierta.\n\nValoramos tu perfil y podremos tenerlo en cuenta para futuras oportunidades, conforme a nuestra Política de Tratamiento de Datos Personales.\n\nCordialmente,\nEquipo de Selección\n[empresa]')
ON CONFLICT (company_id, template_key) DO NOTHING;

-- Correo de ejemplo
INSERT INTO selektor.email_logs (id, company_id, candidate_id, template_key, to_email, subject, body, sent_at) VALUES
  ('10000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'd0000000-0000-4000-8000-000000000001',
   'interview_invitation', 'mariana.lopez@gmail.com',
   'Invitación a entrevista para Cajero — Sede Laureles', '(enviado)', '2026-06-07 10:12:00-05')
ON CONFLICT (id) DO NOTHING;

-- ┌──────────────────────────────────────────────────────────────────────────
-- │ SECCIÓN: 006_selektor_thew.sql
-- └──────────────────────────────────────────────────────────────────────────
-- ============================================================================
-- SELEKTOR · Migración 006 — Empresa The W (multi-empresa) + campos nuevos
--
-- Solo toca objetos DEL SCHEMA selektor (los ALTER son sobre tablas propias
-- de Selektor creadas en 001; nada de The W-producto ni public se modifica).
-- Idempotente: ADD COLUMN IF NOT EXISTS, UUIDs fijos + ON CONFLICT DO NOTHING.
-- Ejecutar después de 001–005.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Campos nuevos del modelo
-- ---------------------------------------------------------------------------
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS tagline text;
ALTER TABLE selektor.jobs      ADD COLUMN IF NOT EXISTS responsibilities jsonb NOT NULL DEFAULT '[]';

-- Tipo de pregunta "number" (re-crea el CHECK propio de selektor.job_questions)
ALTER TABLE selektor.job_questions DROP CONSTRAINT IF EXISTS job_questions_type_check;
ALTER TABLE selektor.job_questions ADD CONSTRAINT job_questions_type_check
  CHECK (type IN ('short_text','long_text','yes_no','number'));

-- Tagline de la empresa demo existente (solo si aún no tiene)
UPDATE selektor.companies SET tagline = 'Hamburguesas con juego limpio.'
WHERE id = 'a0000000-0000-4000-8000-000000000001' AND tagline IS NULL;

-- ---------------------------------------------------------------------------
-- Empresa The W
-- ---------------------------------------------------------------------------
INSERT INTO selektor.companies (id, name, slug, brand_color, email, tagline) VALUES
  ('a0000000-0000-4000-8000-000000000002', 'The W', 'thew', '#111111', 'talento@thew.co', 'Moda hecha en Medellín. Únete al equipo.')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Vacantes de The W (10, todas active)
-- ---------------------------------------------------------------------------
INSERT INTO selektor.jobs (id, company_id, title, slug, city, modality, contract, salary, description, responsibilities, requirements, benefits, status) VALUES
  ('b0000000-0000-4000-8000-000000000101', 'a0000000-0000-4000-8000-000000000002',
   'Asesor(a) Comercial de Tienda', 'asesor-comercial-tienda', 'Medellín', 'Presencial', 'Tiempo completo', 'A convenir',
   'En The W buscamos personas apasionadas por la moda, el servicio al cliente y las ventas. Serás responsable de brindar una experiencia de compra excepcional, asesorar a los clientes sobre nuestras colecciones y contribuir al cumplimiento de las metas comerciales de la tienda.',
   '["Atender clientes de manera personalizada","Asesorar sobre productos y tendencias","Gestionar el proceso de venta y facturación","Mantener el orden y la presentación del punto de venta","Apoyar en inventarios y reposición de mercancía"]',
   '["Mínimo 1 año de experiencia en ventas o retail","Excelente comunicación","Orientación al cliente","Disponibilidad para trabajar fines de semana"]',
   '["Estabilidad laboral","Incentivos por cumplimiento","Descuentos en productos de la marca","Oportunidades de crecimiento"]',
   'active'),
  ('b0000000-0000-4000-8000-000000000102', 'a0000000-0000-4000-8000-000000000002',
   'Diseñador(a) de Moda', 'disenador-moda', 'Medellín', 'Presencial / Híbrido', 'Término indefinido', 'A convenir',
   'Buscamos un diseñador creativo que participe en el desarrollo de nuevas colecciones, investigación de tendencias y elaboración de fichas técnicas.',
   '["Diseñar nuevas prendas","Crear moodboards y propuestas","Elaborar fichas técnicas","Coordinar con producción y patronaje"]',
   '["Profesional o tecnólogo en Diseño de Moda","Dominio de Illustrator y Photoshop","Portafolio actualizado","Conocimiento en tendencias textiles"]',
   '["Ambiente creativo","Participación en lanzamientos","Desarrollo profesional"]',
   'active'),
  ('b0000000-0000-4000-8000-000000000103', 'a0000000-0000-4000-8000-000000000002',
   'Patronista', 'patronista', 'Medellín', 'Presencial', 'Término indefinido', 'A convenir',
   'Responsable de desarrollar moldes y patrones garantizando el ajuste y calidad de las prendas.',
   '["Elaboración de patrones","Escalado de tallas","Ajustes técnicos","Acompañamiento en muestras"]',
   '["Experiencia mínima de 2 años","Conocimiento en software de patronaje","Atención al detalle"]',
   '[]',
   'active'),
  ('b0000000-0000-4000-8000-000000000104', 'a0000000-0000-4000-8000-000000000002',
   'Coordinador(a) de Producción', 'coordinador-produccion', 'Medellín', 'Presencial', 'Término indefinido', 'A convenir',
   'Liderará la planificación y seguimiento de los procesos de confección para garantizar entregas oportunas y estándares de calidad.',
   '["Coordinar talleres","Supervisar cronogramas","Controlar indicadores","Gestionar incidencias de producción"]',
   '["Experiencia en confección o manufactura textil","Liderazgo","Organización"]',
   '[]',
   'active'),
  ('b0000000-0000-4000-8000-000000000105', 'a0000000-0000-4000-8000-000000000002',
   'Community Manager', 'community-manager', 'Medellín, Colombia', 'Remoto / Híbrido', 'Término indefinido', 'A convenir',
   'Gestionará la presencia digital de The W y fortalecerá la relación con la comunidad.',
   '["Administrar redes sociales","Publicar contenido","Interactuar con la audiencia","Elaborar reportes de métricas"]',
   '["Experiencia en manejo de redes","Excelente redacción","Creatividad"]',
   '[]',
   'active'),
  ('b0000000-0000-4000-8000-000000000106', 'a0000000-0000-4000-8000-000000000002',
   'Creador(a) de Contenido Audiovisual', 'creador-contenido-audiovisual', 'Medellín', 'Presencial', 'Término indefinido', 'A convenir',
   'Producirá fotografías y videos para campañas, redes sociales y lanzamientos de producto.',
   '["Grabar contenido","Editar piezas audiovisuales","Coordinar sesiones fotográficas","Mantener coherencia visual de la marca"]',
   '["Manejo de cámaras y edición","Dominio de Premiere o DaVinci Resolve","Portafolio demostrable"]',
   '[]',
   'active'),
  ('b0000000-0000-4000-8000-000000000107', 'a0000000-0000-4000-8000-000000000002',
   'Analista de E-commerce', 'analista-ecommerce', 'Medellín, Colombia', 'Híbrido', 'Término indefinido', 'A convenir',
   'Será responsable de optimizar el rendimiento de la tienda en línea y apoyar las estrategias digitales de venta.',
   '["Gestionar catálogo web","Analizar métricas","Coordinar promociones","Supervisar inventario digital"]',
   '["Experiencia en plataformas e-commerce","Conocimientos de analítica web","Orientación a resultados"]',
   '[]',
   'active'),
  ('b0000000-0000-4000-8000-000000000108', 'a0000000-0000-4000-8000-000000000002',
   'Auxiliar de Logística e Inventarios', 'auxiliar-logistica-inventarios', 'Medellín', 'Presencial', 'Término indefinido', 'A convenir',
   'Apoyará el control de inventarios, recepción y despacho de mercancía.',
   '["Registrar entradas y salidas","Preparar pedidos","Organizar bodega","Apoyar inventarios cíclicos"]',
   '["Experiencia en logística","Organización","Manejo básico de herramientas ofimáticas"]',
   '[]',
   'active'),
  ('b0000000-0000-4000-8000-000000000109', 'a0000000-0000-4000-8000-000000000002',
   'Visual Merchandiser', 'visual-merchandiser', 'Medellín', 'Presencial', 'Término indefinido', 'A convenir',
   'Encargado de diseñar la presentación visual de las tiendas y vitrinas para fortalecer la experiencia de marca.',
   '["Montaje de vitrinas","Organización de exhibiciones","Implementación de lineamientos visuales","Coordinación con marketing"]',
   '["Formación o experiencia en visual merchandising","Buen sentido estético","Creatividad"]',
   '[]',
   'active'),
  ('b0000000-0000-4000-8000-000000000110', 'a0000000-0000-4000-8000-000000000002',
   'Gerente de Tienda', 'gerente-tienda', 'Medellín', 'Presencial', 'Término indefinido', 'A convenir',
   'Liderará la operación integral del punto de venta, el equipo comercial y el cumplimiento de objetivos estratégicos.',
   '["Dirigir el equipo","Supervisar ventas","Gestionar inventario","Garantizar la experiencia del cliente","Elaborar informes de gestión"]',
   '["Mínimo 3 años liderando equipos en retail","Habilidades comerciales","Liderazgo y toma de decisiones"]',
   '["Salario competitivo","Bonificaciones por desempeño","Desarrollo de carrera","Descuentos exclusivos en productos The W"]',
   'active')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Preguntas de las vacantes de The W
-- ---------------------------------------------------------------------------
INSERT INTO selektor.job_questions (id, job_id, label, type, required, position) VALUES
  ('c0000000-0000-4000-8000-000000000111', 'b0000000-0000-4000-8000-000000000101', '¿Por qué quieres trabajar en The W?', 'long_text', true, 1),
  ('c0000000-0000-4000-8000-000000000112', 'b0000000-0000-4000-8000-000000000101', '¿Tienes disponibilidad los fines de semana?', 'yes_no', true, 2),
  ('c0000000-0000-4000-8000-000000000113', 'b0000000-0000-4000-8000-000000000101', '¿Has trabajado antes en moda o retail?', 'yes_no', true, 3),
  ('c0000000-0000-4000-8000-000000000121', 'b0000000-0000-4000-8000-000000000102', 'Comparte el enlace de tu portafolio', 'short_text', true, 1),
  ('c0000000-0000-4000-8000-000000000122', 'b0000000-0000-4000-8000-000000000102', '¿Qué referente de moda te inspira y por qué?', 'long_text', true, 2),
  ('c0000000-0000-4000-8000-000000000131', 'b0000000-0000-4000-8000-000000000103', '¿Qué software de patronaje manejas?', 'short_text', true, 1),
  ('c0000000-0000-4000-8000-000000000141', 'b0000000-0000-4000-8000-000000000104', '¿Cuántas personas has tenido a cargo?', 'number', true, 1),
  ('c0000000-0000-4000-8000-000000000142', 'b0000000-0000-4000-8000-000000000104', 'Cuéntanos un logro en producción del que estés orgulloso(a)', 'long_text', true, 2),
  ('c0000000-0000-4000-8000-000000000151', 'b0000000-0000-4000-8000-000000000105', 'Comparte el enlace de una cuenta que hayas gestionado', 'short_text', true, 1),
  ('c0000000-0000-4000-8000-000000000161', 'b0000000-0000-4000-8000-000000000106', 'Comparte el enlace de tu portafolio o reel', 'short_text', true, 1),
  ('c0000000-0000-4000-8000-000000000162', 'b0000000-0000-4000-8000-000000000106', '¿Qué software de edición dominas?', 'short_text', true, 2),
  ('c0000000-0000-4000-8000-000000000171', 'b0000000-0000-4000-8000-000000000107', '¿Qué plataformas de e-commerce has manejado?', 'short_text', true, 1),
  ('c0000000-0000-4000-8000-000000000181', 'b0000000-0000-4000-8000-000000000108', '¿Tienes experiencia con sistemas de inventario? ¿Cuáles?', 'short_text', false, 1),
  ('c0000000-0000-4000-8000-000000000191', 'b0000000-0000-4000-8000-000000000109', 'Comparte fotos o enlace de vitrinas/montajes que hayas hecho', 'short_text', true, 1),
  ('c0000000-0000-4000-8000-0000000001a1', 'b0000000-0000-4000-8000-000000000110', '¿Cuántas personas has liderado y en qué tipo de tienda?', 'long_text', true, 1),
  ('c0000000-0000-4000-8000-0000000001a2', 'b0000000-0000-4000-8000-000000000110', '¿Cuál es tu aspiración salarial?', 'short_text', true, 2)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Plantillas de correo de The W (mismas 7 bases; editables desde el panel)
-- ---------------------------------------------------------------------------
INSERT INTO selektor.email_templates (company_id, template_key, name, subject, body)
SELECT 'a0000000-0000-4000-8000-000000000002', t.template_key, t.name, t.subject, t.body
FROM selektor.email_templates t
WHERE t.company_id = 'a0000000-0000-4000-8000-000000000001'
ON CONFLICT (company_id, template_key) DO NOTHING;

-- ============================== FIN DEL SETUP ==============================
