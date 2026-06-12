"use client";

import { useSelektor } from "../lib/store";
import { ESTADOS, ORDER } from "../data/estados";
import { Stat } from "./ui";

export default function Dashboard({ setSection }) {
  const { jobs, cands, brand } = useSelektor();
  const myJobs = jobs.filter(j => j.companyId === brand.id);
  const myCands = cands.filter(c => c.companyId === brand.id);
  const counts = ORDER.map(s => [s, myCands.filter(c=>c.status===s).length]);
  const max = Math.max(1, ...counts.map(x=>x[1]));
  return (
    <div>
      <h1 className="sk-display text-xl font-bold mb-4">Resumen del proceso · {brand.name}</h1>
      <div className="grid grid-cols-2 gap-3 mb-5">
        <Stat label="Vacantes activas" value={myJobs.filter(j=>j.status==="active").length} onClick={()=>setSection("jobs")} />
        <Stat label="Total aspirantes" value={myCands.length} onClick={()=>setSection("cands")} />
      </div>
      <div className="bg-white border border-gray-200 rounded-2xl p-4">
        <p className="sk-display font-semibold text-sm mb-3">Aspirantes por estado</p>
        <div className="space-y-2.5">
          {counts.map(([s,n]) => {
            const e = ESTADOS[s];
            return (
              <div key={s} className="flex items-center gap-3 text-xs">
                <span className="w-40 shrink-0 flex items-center gap-1.5 text-gray-700"><span className="w-2 h-2 rounded-full" style={{background:e.dot}} />{e.label}</span>
                <div className="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden"><div className="h-full rounded-full" style={{width:`${(n/max)*100}%`, background:e.dot}} /></div>
                <span className="w-5 text-right font-semibold">{n}</span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
