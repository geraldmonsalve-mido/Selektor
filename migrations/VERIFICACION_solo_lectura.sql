-- ============================================================================
-- SELEKTOR · Verificación SOLO LECTURA (correr ANTES y DESPUÉS del setup)
-- No modifica nada. Compara los resultados de las dos corridas:
--  · ANTES: las queries 1–3 deben devolver vacío (el schema selektor no existe)
--    y la 4 muestra los buckets actuales de The W (si los hay).
--  · DESPUÉS: 1 = 11 tablas; 2 = solo políticas selektor_*; 3 = conteos de
--    seed (2 empresas, 12 vacantes, 3 candidatos, 14 plantillas);
--    4 = los mismos buckets de antes + los 2 nuevos selektor-*;
--    5 y 6 = idénticas a la corrida de ANTES (prueba de que public no cambió).
-- ============================================================================

-- 1. Tablas del schema selektor (ANTES: vacío · DESPUÉS: 11 filas)
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'selektor' ORDER BY 1;

-- 2. Políticas RLS del schema selektor y de storage con prefijo selektor_
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'selektor' OR policyname LIKE 'selektor_%'
ORDER BY schemaname, tablename, policyname;

-- 3. Conteos de datos seed (DESPUÉS: companies=2, jobs=12, candidates=3,
--    email_templates=14, job_questions=20)
SELECT 'companies' objeto, count(*) FROM selektor.companies
UNION ALL SELECT 'jobs', count(*) FROM selektor.jobs
UNION ALL SELECT 'job_questions', count(*) FROM selektor.job_questions
UNION ALL SELECT 'candidates', count(*) FROM selektor.candidates
UNION ALL SELECT 'email_templates', count(*) FROM selektor.email_templates
UNION ALL SELECT 'email_logs', count(*) FROM selektor.email_logs;
-- (Si corres esto ANTES del setup dará error "relation does not exist": es
--  esperado; omite la query 3 en la corrida de ANTES.)

-- 4. Buckets de Storage (DESPUÉS: los de antes + 2 nuevos selektor-*)
SELECT id, name, public, created_at FROM storage.buckets ORDER BY created_at;

-- 5. Snapshot de las tablas de public (debe ser IDÉNTICO antes y después)
SELECT table_name, table_type FROM information_schema.tables
WHERE table_schema = 'public' ORDER BY 1;

-- 6. Snapshot de políticas de public (debe ser IDÉNTICO antes y después)
SELECT tablename, policyname, cmd FROM pg_policies
WHERE schemaname = 'public' ORDER BY 1, 2;
