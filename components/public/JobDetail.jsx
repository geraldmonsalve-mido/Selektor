"use client";

import { useEffect, useRef, useState } from "react";
import ApplyForm from "./ApplyForm";

const PROCESS_STEPS = [
  ["Postulas", "Completas el formulario en menos de 5 minutos."],
  ["Revisamos tu perfil", "El equipo de selección estudia tu experiencia y respuestas."],
  ["Te contactamos", "Si tu perfil avanza, te escribimos por correo."],
  ["Entrevista", "Conversamos contigo, en persona o de forma virtual."],
  ["Decisión y respuesta", "Te confirmamos el resultado, avances o no. Siempre respondemos."],
];

const ListCard = ({ icon, title, items, accent, delay }) => (
  <div className={`bg-white border border-gray-200/80 rounded-2xl p-5 card-hover anim-rise ${delay}`}>
    <p className="text-xl mb-2.5">{icon}</p>
    <p className="sk-display font-semibold text-sm mb-3">{title}</p>
    <ul className="text-[13px] text-gray-600 space-y-2 leading-relaxed">
      {items.map(i => <li key={i} className="flex gap-2.5"><span className="mt-[3px] w-1 h-1 rounded-full shrink-0" style={{background:accent}} />{i}</li>)}
    </ul>
  </div>
);

/* Panel derecho: hero editorial + contenido de la vacante + flujo de postulación */
export default function JobDetail({ company, job }) {
  const [step, setStep] = useState("detail"); // detail | form | done
  const [saved, setSaved] = useState(false);
  const [doneEmail, setDoneEmail] = useState("");
  const topRef = useRef(null);
  const c = company.color;

  // Al cambiar de vacante o de paso, sube suavemente al inicio del panel
  useEffect(() => {
    if (!topRef.current) return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    topRef.current.scrollIntoView({ block: "start", behavior: reduce ? "auto" : "smooth" });
  }, [job.id, step]);

  if (job.status === "closed") return (
    <div ref={topRef} className="anim-fade-up scroll-mt-24">
      <div className="bg-[#0B0B0B] bg-noise rounded-3xl px-8 py-20 lg:py-28 text-center text-white overflow-hidden">
        <p className="text-[11px] uppercase tracking-[0.3em] text-white/40 mb-5">Proceso cerrado</p>
        <h2 className="sk-display text-3xl lg:text-4xl font-bold tracking-tight mb-4">Esta vacante ya fue cubierta</h2>
        <p className="text-sm text-white/55 max-w-md mx-auto leading-relaxed">Gracias por tu interés en <b className="text-white/80">{job.title}</b>. Explora las demás oportunidades de {company.name} en esta página.</p>
      </div>
    </div>
  );

  if (step === "done") return (
    <div ref={topRef} className="anim-fade-up scroll-mt-24">
      <div className="bg-white border border-gray-200/80 rounded-3xl px-8 py-16 text-center">
        <div className="w-14 h-14 rounded-full mx-auto mb-6 flex items-center justify-center text-2xl text-white" style={{background:c}}>✓</div>
        <h2 className="sk-display text-3xl font-bold tracking-tight mb-3">Postulación enviada</h2>
        <p className="text-sm text-gray-500 max-w-md mx-auto leading-relaxed mb-8">Te enviamos un correo de confirmación a <b className="text-gray-800">{doneEmail}</b>. El equipo de selección de {company.name} revisará tu perfil y te contactará si avanzas en el proceso.</p>
        <button onClick={() => setStep("detail")} className="text-sm font-medium underline underline-offset-4" style={{color:c}}>Volver a la vacante</button>
      </div>
    </div>
  );

  if (step === "form") return (
    <div ref={topRef} className="scroll-mt-24">
      <ApplyForm company={company} job={job} onBack={()=>setStep("detail")} onDone={(f)=>{ setDoneEmail(f.email); setStep("done"); }} />
    </div>
  );

  /* ---------- Detalle ---------- */
  const chips = [["📍", job.city], ["🏢", job.modality], ["🕒", job.contract], ["💰", job.salary || "A convenir"]].filter(([,v]) => v);

  return (
    <div ref={topRef} key={job.id} className="anim-fade-up scroll-mt-24">
      {/* Hero editorial */}
      <div className="bg-noise rounded-3xl overflow-hidden relative h-52 lg:h-72 mb-8"
        style={company.heroImageUrl
          ? { backgroundImage:`url(${company.heroImageUrl})`, backgroundSize:"cover", backgroundPosition:"center" }
          : { background:"linear-gradient(118deg, #060606 0%, #141414 46%, #1d1d1f 72%, #101010 100%)" }}>
        <div className="absolute inset-0" style={{background:"linear-gradient(to top, rgba(0,0,0,0.55), rgba(0,0,0,0.08) 55%)"}} />
        {/* acentos geométricos mínimos */}
        {!company.heroImageUrl && <>
          <div className="absolute -right-16 -top-24 w-72 h-72 rounded-full opacity-[0.07]" style={{background:`radial-gradient(circle, ${c}, transparent 70%)`}} />
          <div className="absolute right-12 bottom-10 hidden lg:block w-px h-24 bg-white/15" />
          <div className="absolute right-12 bottom-10 hidden lg:block w-24 h-px bg-white/15" />
        </>}
        <p className="absolute left-7 lg:left-10 bottom-7 lg:bottom-9 sk-display text-white font-bold tracking-tight leading-tight text-2xl lg:text-4xl max-w-md">
          {company.heroPhrase || company.tagline}
        </p>
      </div>

      {/* Título + CTA */}
      <div className="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-5 mb-6">
        <div className="min-w-0">
          <h2 className="sk-display text-4xl lg:text-5xl font-bold tracking-tight leading-[1.02] mb-4">{job.title}</h2>
          <div className="flex flex-wrap gap-2">
            {chips.map(([icon, label]) => (
              <span key={label} className="inline-flex items-center gap-1.5 bg-black/[0.04] border border-black/[0.05] rounded-full px-3.5 py-1.5 text-xs text-gray-700">
                <span className="text-[13px] leading-none">{icon}</span>{label}
              </span>
            ))}
          </div>
        </div>
        <div className="hidden lg:flex items-center gap-2.5 shrink-0 pt-1">
          <button onClick={()=>setSaved(s=>!s)} aria-pressed={saved}
            className={`px-4 py-2.5 rounded-xl text-sm border transition-colors ${saved?"border-gray-800 text-gray-900 bg-gray-50":"border-gray-200 text-gray-600 hover:border-gray-400"}`}>
            {saved ? "♥ Guardada" : "♡ Guardar vacante"}
          </button>
          <button onClick={()=>setStep("form")} className="px-6 py-2.5 rounded-xl text-sm font-semibold text-white transition-all hover:brightness-110 shadow-md" style={{background:c}}>
            Postularme ahora
          </button>
        </div>
      </div>

      <p className="text-[15px] text-gray-600 leading-relaxed max-w-2xl mb-10">{job.description}</p>

      {/* Responsabilidades / Requisitos / Beneficios */}
      <div className="grid md:grid-cols-3 gap-4 mb-10">
        {(job.responsibilities ?? []).length > 0 && <ListCard icon="🎯" title="Responsabilidades" items={job.responsibilities} accent={c} delay="anim-rise-1" />}
        {(job.requirements ?? []).length > 0 && <ListCard icon="📋" title="Requisitos" items={job.requirements} accent={c} delay="anim-rise-2" />}
        {(job.benefits ?? []).length > 0 && <ListCard icon="🎁" title="Beneficios" items={job.benefits} accent={c} delay="anim-rise-3" />}
      </div>

      {/* ¿Por qué unirte? */}
      {company.whyJoin && (
        <div className="bg-[#0B0B0B] bg-noise rounded-3xl p-8 lg:p-10 text-white mb-10 overflow-hidden relative">
          <p className="text-[11px] uppercase tracking-[0.3em] text-white/40 mb-4">¿Por qué unirte a nuestro equipo?</p>
          <p className="text-[15px] lg:text-base leading-relaxed text-white/75 max-w-2xl">{company.whyJoin}</p>
        </div>
      )}

      {/* Beneficios de la empresa (perks) */}
      {(company.perks ?? []).length > 0 && (
        <div className="mb-10">
          <p className="text-[11px] uppercase tracking-[0.25em] text-gray-400 mb-4">Lo que ofrecemos</p>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {company.perks.map(p => {
              const [icon, ...rest] = p.split(" ");
              return (
                <div key={p} className="bg-white border border-gray-200/80 rounded-2xl px-4 py-4 card-hover">
                  <p className="text-xl mb-1.5">{icon}</p>
                  <p className="text-[13px] font-medium text-gray-700">{rest.join(" ")}</p>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Proceso de selección */}
      <div className="bg-white border border-gray-200/80 rounded-3xl p-7 lg:p-9 mb-10">
        <p className="text-[11px] uppercase tracking-[0.25em] text-gray-400 mb-6">Nuestro proceso de selección</p>
        <ol className="space-y-5">
          {PROCESS_STEPS.map(([title, desc], i) => (
            <li key={title} className="flex gap-4">
              <span className="w-7 h-7 rounded-full flex items-center justify-center text-[11px] font-bold text-white shrink-0 mt-0.5" style={{background: i===0 ? c : "#0B0B0B"}}>{i+1}</span>
              <div>
                <p className="text-sm font-semibold text-gray-900">{title}</p>
                <p className="text-[13px] text-gray-500 leading-relaxed">{desc}</p>
              </div>
            </li>
          ))}
        </ol>
      </div>

      {/* CTA final */}
      <div className="hidden lg:flex justify-center mb-4">
        <button onClick={()=>setStep("form")} className="px-10 py-3.5 rounded-xl text-sm font-semibold text-white transition-all hover:brightness-110 shadow-lg" style={{background:c}}>
          Postularme ahora
        </button>
      </div>

      {/* CTA sticky en móvil */}
      <div className="lg:hidden fixed bottom-0 inset-x-0 z-20 px-4 pb-4 pt-8 pointer-events-none" style={{background:"linear-gradient(to top, rgba(250,250,248,0.96) 55%, transparent)"}}>
        <button onClick={()=>setStep("form")} className="pointer-events-auto w-full py-3.5 rounded-xl text-sm font-semibold text-white shadow-xl" style={{background:c}}>
          Postularme ahora
        </button>
      </div>
      <div className="h-16 lg:hidden" />
    </div>
  );
}
