"use client";

import { useState, useMemo } from "react";
import { useSelektor } from "../lib/store";
import { ESTADOS, ORDER } from "../data/estados";
import { Pill } from "./ui";

export default function Cands({ setSection, setProfileId }) {
  const { cands, jobs, brand } = useSelektor();
  const [fStatus, setFStatus] = useState("all");
  const [fJob, setFJob] = useState("all");
  const [q, setQ] = useState("");
  const myJobs = jobs.filter(j => j.companyId === brand.id);
  const list = useMemo(() => cands.filter(c =>
    c.companyId === brand.id &&
    (fStatus==="all"||c.status===fStatus) &&
    (fJob==="all"||String(c.jobId)===fJob) &&
    (q===""||c.name.toLowerCase().includes(q.toLowerCase())||c.city.toLowerCase().includes(q.toLowerCase()))
  ), [cands,brand.id,fStatus,fJob,q]);
  return (
    <div>
      <h1 className="sk-display text-xl font-bold mb-4">Aspirantes · {brand.name}</h1>
      <div className="flex gap-2 mb-4 flex-wrap">
        <input value={q} onChange={e=>setQ(e.target.value)} placeholder="Buscar por nombre o ciudad" className="flex-1 min-w-[160px] border border-gray-300 rounded-lg px-3 py-2 text-sm bg-white" />
        <select value={fStatus} onChange={e=>setFStatus(e.target.value)} className="border border-gray-300 rounded-lg px-2 py-2 text-sm bg-white">
          <option value="all">Todos los estados</option>
          {ORDER.map(s => <option key={s} value={s}>{ESTADOS[s].emoji} {ESTADOS[s].label}</option>)}
        </select>
        <select value={fJob} onChange={e=>setFJob(e.target.value)} className="border border-gray-300 rounded-lg px-2 py-2 text-sm bg-white">
          <option value="all">Todas las vacantes</option>
          {myJobs.map(j => <option key={j.id} value={String(j.id)}>{j.title}</option>)}
        </select>
      </div>
      {list.length === 0 ? (
        <p className="text-sm text-gray-500 text-center py-10">No hay aspirantes con estos filtros. Ajusta la búsqueda o comparte el enlace de la vacante.</p>
      ) : (
        <div className="space-y-2">
          {list.map(c => (
            <button key={c.id} onClick={() => { setProfileId(c.id); setSection("profile"); }}
              className="w-full bg-white border border-gray-200 rounded-xl p-3.5 flex items-center justify-between gap-3 text-left hover:border-gray-400 transition">
              <div className="min-w-0">
                <p className="font-medium text-sm truncate">{c.name}</p>
                <p className="text-xs text-gray-500 truncate">{jobs.find(j=>j.id===c.jobId)?.title} · {c.city} · {c.date}</p>
              </div>
              <Pill status={c.status} small />
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
