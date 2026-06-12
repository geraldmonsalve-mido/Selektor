/* ================== UTILIDADES ================== */
/** Reemplaza variables [clave] dentro de un texto de plantilla. */
export const fill = (txt, vars) => Object.entries(vars).reduce((t,[k,v]) => t.split(`[${k}]`).join(v ?? ""), txt);

/** Slug limpio a partir de un título: sin tildes, minúsculas, guiones. */
export const slugify = (txt) => (txt ?? "")
  .normalize("NFD").replace(/[̀-ͯ]/g, "")
  .toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-+|-+$)/g, "");
