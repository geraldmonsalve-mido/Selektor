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
