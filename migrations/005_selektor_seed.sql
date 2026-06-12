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
