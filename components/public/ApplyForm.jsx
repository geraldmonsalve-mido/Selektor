"use client";

import { useState } from "react";
import { useSelektor } from "../../lib/store";

/* Formulario de postulación: misma lógica, campos y validación que la versión
   anterior (addCandidate(job, f) + Habeas Data), reestilizado al diseño premium. */

const FieldShell = ({ label, children }) => (
  <div className="mb-4">
    <label className="block text-[11px] font-medium uppercase tracking-[0.14em] text-gray-500 mb-1.5">{label}</label>
    {children}
  </div>
);

const inputCls = "w-full border border-gray-200 rounded-xl px-3.5 py-2.5 text-sm bg-white placeholder:text-gray-300 focus:border-gray-400 transition-colors";

const Field = ({ label, value, onChange, type="text", placeholder }) => (
  <FieldShell label={label}>
    <input type={type} value={value} placeholder={placeholder} onChange={e=>onChange(e.target.value)} className={inputCls} />
  </FieldShell>
);

const Block = ({ title, children }) => (
  <section className="bg-white border border-gray-200/80 rounded-2xl p-5 lg:p-6 mb-4">
    <p className="sk-display font-semibold text-sm mb-4">{title}</p>
    {children}
  </section>
);

export default function ApplyForm({ company, job, onBack, onDone }) {
  const { addCandidate } = useSelektor();
  const [f, setF] = useState({ name:"", doc:"", city:"", phone:"", email:"", lastJob:"", years:"", salary:"", availability:"Inmediata", answers:{}, files:[], habeas:false });
  const c = company.color;
  const set = (k,v) => setF(p => ({...p,[k]:v}));
  const valid = f.name && f.doc && f.phone && f.email && f.habeas;

  return (
    <div className="anim-fade-up">
      <button onClick={onBack} className="text-xs text-gray-500 hover:text-gray-800 transition-colors mb-5">← Volver a la vacante</button>
      <h2 className="sk-display text-2xl lg:text-3xl font-bold tracking-tight mb-1">Postulación</h2>
      <p className="text-xs text-gray-500 mb-7">{job.title} · {company.name} · {job.city}</p>

      <Block title="Datos personales">
        <Field label="Nombre completo *" value={f.name} onChange={v=>set("name",v)} />
        <div className="grid grid-cols-2 gap-3">
          <Field label="Documento *" value={f.doc} onChange={v=>set("doc",v)} placeholder="CC 1.000.000.000" />
          <Field label="Ciudad" value={f.city} onChange={v=>set("city",v)} />
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Field label="Teléfono / WhatsApp *" value={f.phone} onChange={v=>set("phone",v)} />
          <Field label="Correo electrónico *" value={f.email} onChange={v=>set("email",v)} type="email" />
        </div>
      </Block>

      <Block title="Perfil profesional">
        <Field label="Último cargo y empresa" value={f.lastJob} onChange={v=>set("lastJob",v)} placeholder="Asesora — Tienda de moda" />
        <div className="grid grid-cols-2 gap-3">
          <Field label="Años de experiencia" value={f.years} onChange={v=>set("years",v)} type="number" />
          <Field label="Aspiración salarial" value={f.salary} onChange={v=>set("salary",v)} placeholder="$1.700.000" />
        </div>
        <FieldShell label="Disponibilidad">
          <select value={f.availability} onChange={e=>set("availability",e.target.value)} className={inputCls}>
            <option>Inmediata</option><option>15 días</option><option>30 días</option>
          </select>
        </FieldShell>
      </Block>

      <Block title="Preguntas de la vacante">
        {job.questions.map(q => (
          <div key={q.id} className="mb-4 last:mb-0">
            <label className="block text-[11px] font-medium uppercase tracking-[0.14em] text-gray-500 mb-1.5">{q.label}{q.required && " *"}</label>
            {q.type === "yes_no" ? (
              <div className="flex gap-2">
                {["Sí","No"].map(o => (
                  <button key={o} type="button" onClick={()=>set("answers",{...f.answers,[q.id]:o})}
                    className={`px-5 py-2 rounded-xl text-sm border transition-colors ${f.answers[q.id]===o?"text-white border-transparent":"border-gray-200 bg-white text-gray-700 hover:border-gray-400"}`}
                    style={f.answers[q.id]===o?{background:c}:{}}>{o}</button>
                ))}
              </div>
            ) : q.type === "long_text" ? (
              <textarea rows={3} value={f.answers[q.id]||""} onChange={e=>set("answers",{...f.answers,[q.id]:e.target.value})} className={inputCls} />
            ) : q.type === "number" ? (
              <input type="number" min="0" value={f.answers[q.id]||""} onChange={e=>set("answers",{...f.answers,[q.id]:e.target.value})} className={inputCls} />
            ) : (
              <input value={f.answers[q.id]||""} onChange={e=>set("answers",{...f.answers,[q.id]:e.target.value})} className={inputCls} />
            )}
          </div>
        ))}
      </Block>

      <Block title="Documentos">
        <p className="text-xs text-gray-400 mb-3">PDF, DOC, JPG, PNG · máx. 10 MB por archivo · máx. 5 archivos</p>
        {["Hoja de vida","Cédula","Certificados"].map(d => {
          const on = f.files.includes(d);
          return (
            <button key={d} type="button" onClick={()=>set("files", on ? f.files.filter(x=>x!==d) : [...f.files,d])}
              className={`w-full flex items-center justify-between border rounded-xl px-4 py-3 text-sm mb-2 transition-colors ${on?"bg-gray-50 border-gray-300":"border-dashed border-gray-200 bg-white hover:border-gray-300"}`}>
              <span>{on?"📎":"⬆️"} {d}{on && <span className="text-gray-400 text-xs"> · {d.toLowerCase().replace(/ /g,"-")}.pdf</span>}</span>
              <span className="text-xs font-medium" style={{color:c}}>{on?"Quitar":"Adjuntar"}</span>
            </button>
          );
        })}
      </Block>

      <label className="flex items-start gap-3 bg-white border border-gray-200/80 rounded-2xl p-4 text-xs text-gray-500 leading-relaxed mb-6 cursor-pointer">
        <input type="checkbox" checked={f.habeas} onChange={e=>set("habeas",e.target.checked)} className="mt-0.5" />
        <span>Autorizo de manera previa, expresa e informada el tratamiento de mis datos personales por parte de <b className="text-gray-700">{company.name}</b> (responsable) y <b className="text-gray-700">Selektor</b> (encargado), exclusivamente para fines de reclutamiento y selección, conforme a la Ley 1581 de 2012 y el Decreto 1377 de 2013. He leído la <span className="underline" style={{color:c}}>Política de Tratamiento de Datos Personales</span>.</span>
      </label>

      <button disabled={!valid} onClick={() => { addCandidate(job, f); onDone(f); }}
        className="w-full py-3.5 rounded-xl text-white font-semibold text-sm disabled:opacity-30 transition-all hover:brightness-110 shadow-lg" style={{background:c}}>
        Enviar postulación
      </button>
    </div>
  );
}
