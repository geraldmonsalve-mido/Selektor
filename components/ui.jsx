"use client";

import { ESTADOS } from "../data/estados";

/* ================== ELEMENTOS UI COMPARTIDOS ================== */

export function Pill({ status, small }) {
  const e = ESTADOS[status];
  return (
    <span className={`inline-flex items-center gap-1.5 rounded-full font-medium ${small?"px-2 py-0.5 text-[11px]":"px-2.5 py-1 text-xs"}`} style={{ background:e.bg, color:e.fg }}>
      <span className="w-1.5 h-1.5 rounded-full" style={{ background:e.dot }} /> {e.label}
    </span>
  );
}

export const Section = ({ title, children }) => (
  <div className="mb-6">
    <p className="sk-display font-semibold text-sm mb-3">{title}</p>
    {children}
  </div>
);

export const Input = ({ label, value, onChange, type="text", placeholder }) => (
  <div className="mb-3">
    <label className="block text-xs font-medium text-gray-600 mb-1">{label}</label>
    <input type={type} value={value} placeholder={placeholder} onChange={e=>onChange(e.target.value)} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm bg-white" />
  </div>
);

export const Stat = ({ label, value, onClick }) => (
  <button onClick={onClick} className="bg-white border border-gray-200 rounded-2xl p-4 text-left hover:border-gray-400 transition">
    <p className="sk-display text-2xl font-bold">{value}</p>
    <p className="text-xs text-gray-500">{label}</p>
  </button>
);

export const Act = ({ children, on, disabled, danger, gold }) => (
  <button onClick={on} disabled={disabled}
    className={`rounded-xl px-3 py-2.5 text-sm font-medium border text-left disabled:opacity-35 transition
      ${gold?"border-amber-300 bg-amber-50":danger?"border-red-200 bg-red-50":"border-gray-200 bg-gray-50 hover:border-gray-400"}`}>
    {children}
  </button>
);

export const Lbl = ({ t, children }) => <label className="block text-xs font-medium text-gray-600 mb-2.5">{t}{children}</label>;

export const Row = ({ k, v }) => (
  <div className="flex justify-between gap-4 text-sm py-1.5 border-b border-gray-100 last:border-0">
    <span className="text-gray-500">{k}</span><span className="text-right font-medium">{v||"—"}</span>
  </div>
);

export function Modal({ title, children, close }) {
  return (
    <div className="fixed inset-0 bg-black/40 z-40 flex items-end sm:items-center justify-center p-3" onClick={close}>
      <div className="bg-white rounded-2xl w-full max-w-md p-5 max-h-[88vh] overflow-y-auto" onClick={e=>e.stopPropagation()}>
        <p className="sk-display font-bold mb-3">{title}</p>
        {children}
      </div>
    </div>
  );
}
