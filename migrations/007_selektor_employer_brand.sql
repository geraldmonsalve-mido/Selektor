-- ============================================================================
-- SELEKTOR · Migración 007 — Marca empleadora (experiencia pública premium)
--
-- Solo toca selektor.companies (schema propio). Idempotente:
-- ADD COLUMN IF NOT EXISTS + UPDATEs guardados con IS NULL.
-- NO ejecutar automáticamente: pendiente de correr en el SQL Editor
-- (puede añadirse al final de ALL_selektor_setup.sql).
-- ============================================================================

ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS city           text;
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS industry       text;
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS team_size      text;
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS website        text;
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS hero_image_url text;
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS hero_phrase    text;
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS mission        text;
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS why_join       text;
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS perks          jsonb NOT NULL DEFAULT '[]';
ALTER TABLE selektor.companies ADD COLUMN IF NOT EXISTS footer_tagline text;

-- Acento editorial de The W: #111111 → #B5121B (solo si conserva el valor anterior)
UPDATE selektor.companies SET brand_color = '#B5121B'
WHERE id = 'a0000000-0000-4000-8000-000000000002' AND brand_color = '#111111';

-- Contenido de marca empleadora de The W (solo campos aún vacíos)
UPDATE selektor.companies SET
  city           = COALESCE(city, 'Medellín, Colombia'),
  industry       = COALESCE(industry, 'Moda y diseño'),
  team_size      = COALESCE(team_size, '50–100 personas'),
  website        = COALESCE(website, 'thew.co'),
  hero_phrase    = COALESCE(hero_phrase, 'Hecho en Medellín. Pensado para el mundo.'),
  mission        = COALESCE(mission, 'Diseñamos prendas que nacen de una idea, evolucionan con creatividad y terminan convirtiéndose en identidad para quienes las usan. Creemos en el detalle, en la autenticidad y en el talento que transforma conceptos en experiencias. Cada colección representa una visión contemporánea de la moda hecha en Medellín con proyección internacional. Si compartes nuestra pasión por crear, aprender y construir marcas memorables, queremos conocerte.'),
  why_join       = COALESCE(why_join, 'En The W creemos que la moda es una forma de expresión y que detrás de cada prenda existe un equipo comprometido con la creatividad, la excelencia y la innovación. Promovemos un ambiente donde las ideas tienen espacio para crecer, el talento es reconocido y cada integrante puede aportar una visión única. Buscamos personas apasionadas por aprender, colaborar y construir una marca con propósito.'),
  footer_tagline = COALESCE(footer_tagline, 'Moda con propósito. Diseñada en Medellín. Inspirada por las personas.'),
  perks = CASE WHEN perks = '[]'::jsonb THEN
    '["✨ Desarrollo profesional","🎓 Capacitación continua","🛍️ Descuentos para empleados","🤝 Excelente ambiente","🚀 Crecimiento","💡 Cultura creativa"]'::jsonb
    ELSE perks END
WHERE id = 'a0000000-0000-4000-8000-000000000002';

-- Defaults razonables para la empresa demo (solo campos aún vacíos)
UPDATE selektor.companies SET
  city           = COALESCE(city, 'Medellín, Colombia'),
  industry       = COALESCE(industry, 'Restaurantes'),
  team_size      = COALESCE(team_size, '20–50 personas'),
  website        = COALESCE(website, 'pingpongburger.co'),
  hero_phrase    = COALESCE(hero_phrase, 'Sabor que juega en serio.'),
  mission        = COALESCE(mission, 'Hacemos hamburguesas con ingredientes honestos y un servicio que se siente como jugar en casa. Crecemos sede a sede con equipos que disfrutan el ritmo del servicio y el trabajo bien hecho. Si te gusta la buena cocina y el buen ambiente, este es tu lugar.'),
  why_join       = COALESCE(why_join, 'Somos un equipo cercano donde el esfuerzo se nota y se reconoce. Aquí aprendes el oficio de verdad, creces a tu ritmo y trabajas con personas que disfrutan lo que hacen.'),
  footer_tagline = COALESCE(footer_tagline, 'Hamburguesas con juego limpio. Hechas en Medellín.'),
  perks = CASE WHEN perks = '[]'::jsonb THEN
    '["✨ Desarrollo profesional","🎓 Capacitación continua","🛍️ Descuentos para empleados","🤝 Excelente ambiente","🚀 Crecimiento","💡 Cultura creativa"]'::jsonb
    ELSE perks END
WHERE id = 'a0000000-0000-4000-8000-000000000001';
