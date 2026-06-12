/* Mapa cargo → emoji curado (lucide-react no está instalado; no se agregan librerías) */
const ICON_RULES = [
  [/asesor|comercial|venta|cajero/i, "🛍️"],
  [/diseñador|diseno|diseñ/i, "🎨"],
  [/patron/i, "📐"],
  [/producci/i, "🧵"],
  [/community|redes/i, "📱"],
  [/contenido|audiovisual|foto|video/i, "🎬"],
  [/e-?commerce|digital/i, "🛒"],
  [/log[ií]stica|inventario|bodega/i, "📦"],
  [/visual|merchandis|vitrina/i, "🪞"],
  [/gerente|l[ií]der|director/i, "👔"],
  [/cocina|chef|parrilla/i, "🍔"],
];

export const iconForJob = (title) => (ICON_RULES.find(([re]) => re.test(title))?.[1]) ?? "💼";
