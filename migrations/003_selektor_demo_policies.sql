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
