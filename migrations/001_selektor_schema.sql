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
