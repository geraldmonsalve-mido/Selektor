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
