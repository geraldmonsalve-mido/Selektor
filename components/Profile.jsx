"use client";

import { useState } from "react";
import { useSelektor } from "../lib/store";
import InterviewModal from "./InterviewModal";
import { Pill, Modal, Act, Row } from "./ui";

export default function Profile({ cand, setSection }) {
  const { jobs, setStatus, selectFinal, scheduleInterview, notify } = useSelektor();
  const [showInterview, setShowInterview] = useState(false);
  const [showSelect, setShowSelect] = useState(false);
  if (!cand) return null;
  const job = jobs.find(j => j.id === cand.jobId);
  const canInterview = ["preselected","observation","finalist"].includes(cand.status);
  const canSelect = ["finalist","interview_scheduled","preselected"].includes(cand.status);

  return (
    <div>
      <button onClick={()=>setSection("cands")} className="text-xs text-gray-500 mb-3">← Aspirantes</button>
      <div className="bg-white border border-gray-200 rounded-2xl p-4 mb-4">
        <div className="flex items-start justify-between gap-3 mb-1">
          <h1 className="sk-display text-lg font-bold leading-tight">{cand.name}</h1>
          <Pill status={cand.status} />
        </div>
        <p className="text-xs text-gray-500">{job.title} · postulación {cand.date}</p>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-4 mb-4">
        <p className="sk-display font-semibold text-sm mb-2">Resumen</p>
        <Row k="Documento" v={cand.doc} /><Row k="Ciudad" v={cand.city} /><Row k="Teléfono" v={cand.phone} />
        <Row k="Correo" v={cand.email} /><Row k="Último cargo" v={cand.lastJob} /><Row k="Experiencia" v={`${cand.years} años`} />
        <Row k="Aspiración" v={cand.salary} /><Row k="Disponibilidad" v={cand.availability} />
      </div>

      {cand.answers && Object.keys(cand.answers).length > 0 && (
        <div className="bg-white border border-gray-200 rounded-2xl p-4 mb-4">
          <p className="sk-display font-semibold text-sm mb-2">Respuestas</p>
          {job.questions.map(q => cand.answers[q.id] !== undefined && (
            <div key={q.id} className="mb-2.5"><p className="text-xs text-gray-500">{q.label}</p><p className="text-sm">{String(cand.answers[q.id])}</p></div>
          ))}
        </div>
      )}

      <div className="bg-white border border-gray-200 rounded-2xl p-4 mb-4">
        <p className="sk-display font-semibold text-sm mb-2">Documentos</p>
        {(cand.files||[]).length === 0 ? <p className="text-sm text-gray-400">Sin documentos adjuntos.</p> :
          cand.files.map(f => (
            <div key={f} className="flex items-center justify-between text-sm py-2 border-b border-gray-100 last:border-0">
              <span>📄 {f}</span>
              <div className="flex gap-3 text-xs font-medium text-gray-600">
                <button onClick={()=>notify("Abriendo documento (URL firmada)")}>Ver</button>
                <button onClick={()=>notify("Descargando documento")}>Descargar</button>
              </div>
            </div>
          ))}
      </div>

      {cand.notes && (
        <div className="bg-amber-50 border border-amber-200 rounded-2xl p-3.5 mb-4 text-sm text-amber-900">
          <b>Nota interna:</b> {cand.notes}
        </div>
      )}

      <div className="bg-white border border-gray-200 rounded-2xl p-4">
        <p className="sk-display font-semibold text-sm mb-3">Acciones</p>
        <div className="grid grid-cols-2 gap-2">
          <Act on={()=>setStatus(cand,"preselected","preselected")} disabled={cand.status==="preselected"||cand.status==="selected"}>🟢 Preseleccionar</Act>
          <Act on={()=>setStatus(cand,"observation","observation")} disabled={cand.status==="observation"||cand.status==="selected"}>🟠 En observación</Act>
          <Act on={()=>setShowInterview(true)} disabled={!canInterview}>🔵 Citar entrevista</Act>
          <Act on={()=>setStatus(cand,"finalist")} disabled={cand.status==="finalist"||cand.status==="selected"}>🟣 Marcar finalista</Act>
          <Act on={()=>setStatus(cand,"rejected","rejected")} disabled={cand.status==="rejected"||cand.status==="selected"} danger>🔴 No continúa</Act>
          <Act on={()=>setShowSelect(true)} disabled={!canSelect} gold>⭐ Seleccionar</Act>
        </div>
        <p className="text-[11px] text-gray-400 mt-2.5">Cada cambio de estado envía el correo automático correspondiente y queda registrado.</p>
      </div>

      {showInterview && <InterviewModal cand={cand} job={job} close={()=>setShowInterview(false)} onDone={(d)=>{
        scheduleInterview(cand, job, d);
        setShowInterview(false);
      }} />}

      {showSelect && (
        <Modal close={()=>setShowSelect(false)} title="Confirmar selección">
          <p className="text-sm text-gray-600 mb-4">¿Confirmas que deseas seleccionar a <b>{cand.name}</b> para el cargo <b>{job.title}</b>? Esta acción cerrará la vacante y enviará correos automáticos al candidato seleccionado y al resto de participantes.</p>
          <div className="flex gap-2">
            <button onClick={()=>setShowSelect(false)} className="flex-1 border border-gray-300 rounded-xl py-2.5 text-sm">Cancelar</button>
            <button onClick={()=>{ selectFinal(cand); setShowSelect(false); }} className="flex-1 bg-[#14181F] text-white rounded-xl py-2.5 text-sm font-semibold">⭐ Confirmar selección</button>
          </div>
        </Modal>
      )}
    </div>
  );
}
