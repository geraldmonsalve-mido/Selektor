"use client";

import { useState } from "react";

export default function EmailLog({ emails }) {
  const [open, setOpen] = useState(null);
  return (
    <div>
      <h1 className="sk-display text-xl font-bold mb-4">Correos enviados</h1>
      {emails.length===0 ? <p className="text-sm text-gray-500">Aún no se han enviado correos.</p> : (
        <div className="space-y-2">
          {emails.map(m => (
            <div key={m.id} className="bg-white border border-gray-200 rounded-xl">
              <button onClick={()=>setOpen(open===m.id?null:m.id)} className="w-full p-3.5 text-left">
                <div className="flex justify-between gap-2"><p className="text-sm font-medium truncate">{m.subject}</p><span className="text-[10px] text-emerald-600 font-semibold shrink-0">Enviado ✓</span></div>
                <p className="text-xs text-gray-500 mt-0.5">{m.to} · {m.date}</p>
              </button>
              {open===m.id && <pre className="px-3.5 pb-3.5 text-xs text-gray-600 whitespace-pre-wrap font-sans">{m.body}</pre>}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
