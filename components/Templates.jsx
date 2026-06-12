"use client";

import { useState } from "react";
import { useSelektor } from "../lib/store";

export default function Templates() {
  const { templates, setTemplates, saveTemplate, notify } = useSelektor();
  const [open, setOpen] = useState(null);
  return (
    <div>
      <h1 className="sk-display text-xl font-bold mb-1">Plantillas de correo</h1>
      <p className="text-xs text-gray-500 mb-4">Variables: [nombre] [empresa] [cargo] [fecha_entrevista] [hora_entrevista] [ubicacion_o_link] [nombre_reclutador]</p>
      <div className="space-y-2">
        {Object.entries(templates).map(([k,t]) => (
          <div key={k} className="bg-white border border-gray-200 rounded-xl">
            <button onClick={()=>setOpen(open===k?null:k)} className="w-full flex justify-between items-center p-3.5 text-left">
              <span className="text-sm font-medium">{t.name}</span>
              <span className="text-gray-400 text-xs">{open===k?"Cerrar":"Editar"}</span>
            </button>
            {open===k && (
              <div className="px-3.5 pb-3.5">
                <input value={t.subject} onChange={e=>setTemplates(p=>({...p,[k]:{...t,subject:e.target.value}}))} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm mb-2" />
                <textarea rows={7} value={t.body} onChange={e=>setTemplates(p=>({...p,[k]:{...t,body:e.target.value}}))} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm font-mono text-xs" />
                <button onClick={()=>{ saveTemplate(k); setOpen(null); notify("Plantilla guardada"); }} className="mt-1 bg-[#14181F] text-white rounded-lg px-4 py-2 text-xs font-semibold">Guardar cambios</button>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
