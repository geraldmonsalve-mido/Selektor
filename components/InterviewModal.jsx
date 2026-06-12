"use client";

import { useState } from "react";
import { Modal, Lbl } from "./ui";

export default function InterviewModal({ cand, job, close, onDone }) {
  const [d, setD] = useState({ date:"2026-06-16", start:"10:00", end:"10:45", modality:"Virtual", place:"meet.google.com/skt-demo", recruiter:"Laura M. — Selección", notes:"" });
  const set = (k,v)=>setD(p=>({...p,[k]:v}));
  return (
    <Modal close={close} title={`Citar entrevista · ${cand.name.split(" ")[0]}`}>
      <div className="grid grid-cols-2 gap-3 mb-3">
        <Lbl t="Fecha"><input type="date" value={d.date} onChange={e=>set("date",e.target.value)} className="inp" /></Lbl>
        <Lbl t="Modalidad">
          <select value={d.modality} onChange={e=>set("modality",e.target.value)} className="inp"><option>Virtual</option><option>Presencial</option><option>Telefónica</option></select>
        </Lbl>
        <Lbl t="Hora inicio"><input type="time" value={d.start} onChange={e=>set("start",e.target.value)} className="inp" /></Lbl>
        <Lbl t="Hora fin"><input type="time" value={d.end} onChange={e=>set("end",e.target.value)} className="inp" /></Lbl>
      </div>
      <Lbl t={d.modality==="Presencial"?"Dirección":"Enlace de reunión"}><input value={d.place} onChange={e=>set("place",e.target.value)} className="inp" /></Lbl>
      <Lbl t="Reclutador responsable"><input value={d.recruiter} onChange={e=>set("recruiter",e.target.value)} className="inp" /></Lbl>
      <Lbl t="Notas visibles para el candidato"><textarea rows={2} value={d.notes} onChange={e=>set("notes",e.target.value)} className="inp" /></Lbl>
      <div className="flex gap-2 mt-4">
        <button onClick={close} className="flex-1 border border-gray-300 rounded-xl py-2.5 text-sm">Cancelar</button>
        <button onClick={()=>onDone(d)}
          className="flex-1 bg-[#14181F] text-white rounded-xl py-2.5 text-sm font-semibold">Crear evento y citar</button>
      </div>
      <p className="text-[11px] text-gray-400 mt-2">Crea el evento en Google Calendar, envía la invitación por correo y cambia el estado a 🔵 Entrevista programada.</p>
    </Modal>
  );
}
