// ============================================================================
// SELEKTOR · Check E2E de persistencia en Supabase (correr DESPUÉS de ejecutar
// migrations/ALL_selektor_setup.sql y exponer el schema "selektor").
//
// Valida: (1) la app carga en modo BD (sin warning de fallback), (2) /thew
// muestra las 10 vacantes desde la BD, (3) una postulación nueva sobrevive a
// una recarga completa (F5), prueba definitiva de persistencia.
//
// Uso (con el dev server corriendo en http://localhost:3000):
//   node scripts/e2e-persistencia.mjs
// Lanza su propio Chrome headless; no modifica la app. Inserta 1 candidato de
// prueba en selektor.candidates (datos sintéticos, schema selektor solamente).
// ============================================================================
import { spawn } from "node:child_process";

const CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const CDP_PORT = 9344;
const BASE = "http://localhost:3000";

const chrome = spawn(CHROME, [
  "--headless=new", `--remote-debugging-port=${CDP_PORT}`,
  `--user-data-dir=/tmp/chrome-selektor-persist`, "--no-first-run", "about:blank",
], { stdio: "ignore" });
const cleanup = () => { try { chrome.kill(); } catch {} };
process.on("exit", cleanup);

async function getWsUrl() {
  for (let i = 0; i < 40; i++) {
    try {
      const r = await fetch(`http://127.0.0.1:${CDP_PORT}/json/list`);
      const page = (await r.json()).find(t => t.type === "page");
      if (page) return page.webSocketDebuggerUrl;
    } catch {}
    await new Promise(r => setTimeout(r, 500));
  }
  throw new Error("Sin conexión CDP con Chrome");
}

const ws = new WebSocket(await getWsUrl());
await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
let id = 0;
const pending = new Map();
const warnings = [];
ws.onmessage = (ev) => {
  const m = JSON.parse(ev.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
  if (m.method === "Runtime.consoleAPICalled" && ["error","warning"].includes(m.params.type))
    warnings.push(m.params.args.map(a => a.value ?? a.description ?? "").join(" "));
};
const send = (method, params = {}) => new Promise(res => { const i = ++id; pending.set(i, res); ws.send(JSON.stringify({ id: i, method, params })); });
const evalJs = async (expr) => {
  const r = await send("Runtime.evaluate", { expression: expr, awaitPromise: true, returnByValue: true });
  if (r.result?.exceptionDetails) throw new Error("Eval: " + JSON.stringify(r.result.exceptionDetails));
  return r.result?.result?.value;
};
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const HELPERS = `
  window.__click = (sel, txt) => { const e = [...document.querySelectorAll(sel)].find(x => x.textContent.trim().includes(txt)); if (!e) throw new Error("No encontrado: " + txt); e.click(); return true; };
  window.__setInput = (label, value) => {
    const lab = [...document.querySelectorAll("label")].find(l => l.textContent.includes(label));
    const inp = lab.parentElement.querySelector("input, textarea") || lab.querySelector("input, textarea");
    Object.getOwnPropertyDescriptor(inp.tagName === "TEXTAREA" ? HTMLTextAreaElement.prototype : HTMLInputElement.prototype, "value").set.call(inp, value);
    inp.dispatchEvent(new Event("input", { bubbles: true })); return true;
  }; true;`;

await send("Runtime.enable");
await send("Page.enable");

const results = [];
const step = (name, ok) => { results.push(`${ok ? "✅" : "❌"} ${name}`); if (!ok) { console.log(results.join("\n")); console.log("\nWarnings de consola:\n" + warnings.join("\n")); cleanup(); process.exit(1); } };
const candName = `Persistencia Test ${Date.now()}`;

// 1. /thew en modo BD: 10 vacantes y sin warning de fallback
await send("Page.navigate", { url: `${BASE}/thew` });
await sleep(3500);
await evalJs(HELPERS);
step("App en modo BD (sin warning de fallback a memoria)",
  !warnings.some(w => w.includes("Supabase no disponible") || w.includes("Supabase sin configurar")));
step("/thew carga las 10 vacantes desde la BD", await evalJs(`
  ["Asesor(a) Comercial de Tienda","Diseñador(a) de Moda","Patronista","Coordinador(a) de Producción","Community Manager",
   "Creador(a) de Contenido Audiovisual","Analista de E-commerce","Auxiliar de Logística e Inventarios","Visual Merchandiser","Gerente de Tienda"]
  .every(t => document.body.textContent.includes(t))`));

// 2. Postulación nueva
await send("Page.navigate", { url: `${BASE}/thew/asesor-comercial-tienda` });
await sleep(2500);
await evalJs(HELPERS);
await evalJs(`__click("button", "Postularme")`); await sleep(500);
await evalJs(`__setInput("Nombre completo", ${JSON.stringify(candName)})`);
await evalJs(`__setInput("Documento", "CC 7.777.777")`);
await evalJs(`__setInput("Teléfono", "322 222 2222")`);
await evalJs(`__setInput("Correo electrónico", "persistencia@test.com")`);
await evalJs(`document.querySelector('input[type=checkbox]').click()`); await sleep(300);
await evalJs(`__click("button", "Enviar postulación")`);
await sleep(2500); // margen para el INSERT remoto
step("Postulación enviada", await evalJs(`document.body.textContent.includes("Postulación enviada")`));

// 3. RECARGA COMPLETA (equivale a F5: borra todo estado en memoria)
await send("Page.navigate", { url: `${BASE}/panel` });
await sleep(3500);
await evalJs(HELPERS);
step("Panel recargado en The W", await evalJs(`document.body.textContent.includes("Resumen del proceso · The W")`));
await evalJs(`__click("button", "Aspirantes")`); await sleep(800);
step("PERSISTENCIA: la postulación sobrevive a la recarga (viene de la BD)",
  await evalJs(`document.body.textContent.includes(${JSON.stringify(candName)})`));

// 4. Segunda recarga directa para descartar casualidad
await send("Page.navigate", { url: `${BASE}/panel` });
await sleep(3000);
await evalJs(HELPERS);
await evalJs(`__click("button", "Aspirantes")`); await sleep(800);
step("PERSISTENCIA confirmada en segunda recarga", await evalJs(`document.body.textContent.includes(${JSON.stringify(candName)})`));

console.log(results.join("\n"));
const relevant = warnings.filter(w => !w.includes("React DevTools"));
console.log(relevant.length ? "\n⚠️ Warnings:\n" + relevant.join("\n") : "\n✅ Sin errores ni warnings en consola");
cleanup();
process.exit(0);
