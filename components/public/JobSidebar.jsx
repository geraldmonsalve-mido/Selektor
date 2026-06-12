"use client";

import { useEffect, useRef } from "react";
import { iconForJob } from "./icons";

/* Sidebar de vacantes: lista sticky en desktop, carrusel horizontal con snap
   en móvil. Solo vacantes activas (las cerradas salen de la vista pública). */
export default function JobSidebar({ company, jobs, selected, onSelect }) {
  const refs = useRef({});

  useEffect(() => {
    const el = refs.current[selected?.id];
    if (!el) return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    el.scrollIntoView({ block: "nearest", inline: "center", behavior: reduce ? "auto" : "smooth" });
  }, [selected?.id]);

  const accent = company.color;

  return (
    <aside className="lg:sticky lg:top-8 lg:self-start">
      <p className="hidden lg:flex items-baseline gap-2 text-[11px] uppercase tracking-[0.25em] text-gray-400 mb-4 px-1">
        Vacantes abiertas <span className="text-gray-300">·</span> <span className="text-gray-500">{jobs.length}</span>
      </p>
      <div className="flex lg:flex-col gap-3 overflow-x-auto lg:overflow-visible no-scrollbar snap-x snap-mandatory lg:snap-none -mx-5 px-5 lg:mx-0 lg:px-0 pb-2 lg:pb-0">
        {jobs.map(j => {
          const active = selected?.id === j.id;
          return (
            <button
              key={j.id}
              ref={el => { refs.current[j.id] = el; }}
              onClick={() => onSelect(j)}
              aria-current={active ? "true" : undefined}
              className={`group snap-center shrink-0 lg:shrink w-[265px] lg:w-full text-left bg-white rounded-2xl p-4 card-hover border
                ${active ? "border-transparent shadow-[0_10px_30px_-12px_rgba(10,10,10,0.25)]" : "border-gray-200/80"}`}
              style={active ? { boxShadow: `inset 3px 0 0 ${accent}, 0 10px 30px -12px rgba(10,10,10,0.25)`, background: "#FFFFFF" } : {}}
            >
              <div className="flex items-start gap-3">
                <span className={`w-9 h-9 rounded-xl flex items-center justify-center text-base shrink-0 transition-colors ${active ? "bg-[#0B0B0B]" : "bg-gray-100 group-hover:bg-gray-200/70"}`}>
                  <span className={active ? "grayscale-0" : ""}>{iconForJob(j.title)}</span>
                </span>
                <div className="min-w-0 flex-1">
                  <p className={`text-[13.5px] font-semibold leading-snug ${active ? "text-[#0B0B0B]" : "text-gray-800"}`}>{j.title}</p>
                  <p className="text-[11.5px] text-gray-500 mt-1 truncate">{j.city} · {j.modality}</p>
                  <div className="flex items-center gap-2 mt-2">
                    <span className="text-[10.5px] text-gray-400">{j.contract}</span>
                    <span className="inline-flex items-center gap-1 text-[10px] font-medium" style={{ color: accent }}>
                      <span className="w-1.5 h-1.5 rounded-full" style={{ background: accent }} /> Activa
                    </span>
                  </div>
                </div>
                <span className={`text-gray-300 text-sm mt-0.5 transition-transform ${active ? "translate-x-0.5 text-gray-400" : "group-hover:translate-x-0.5"}`}>›</span>
              </div>
            </button>
          );
        })}
      </div>
    </aside>
  );
}
