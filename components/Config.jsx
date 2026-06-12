"use client";

import { useSelektor } from "../lib/store";
import { Lbl } from "./ui";

const BRAND_COLORS = ["#B5121B","#111111","#F2540B","#0E7B5A","#2547D0","#A21CAF"];
const inputCls = "w-full border border-gray-300 rounded-lg px-3 py-2 text-sm mt-1";

export default function Config() {
  const { brand, setBrand, saveBrand, notify } = useSelektor();
  return (
    <div>
      <h1 className="sk-display text-xl font-bold mb-4">Marca y branding · {brand.name}</h1>

      <div className="bg-white border border-gray-200 rounded-2xl p-4 space-y-4 mb-4">
        <Lbl t="Nombre de la empresa"><input value={brand.name} onChange={e=>setBrand(p=>({...p,name:e.target.value}))} className={inputCls} /></Lbl>
        <Lbl t="Tagline (frase corta)"><input value={brand.tagline ?? ""} onChange={e=>setBrand(p=>({...p,tagline:e.target.value}))} className={inputCls} /></Lbl>
        <Lbl t="Slug público (selektor.app/…)"><input value={brand.slug} onChange={e=>setBrand(p=>({...p,slug:e.target.value.toLowerCase().replace(/[^a-z0-9-]/g,"")}))} className={inputCls} /></Lbl>
        <div>
          <p className="text-xs font-medium text-gray-600 mb-2">Color de acento (estados activos y CTA del sitio público)</p>
          <div className="flex items-center gap-2 flex-wrap">
            {BRAND_COLORS.map(c => (
              <button key={c} onClick={()=>setBrand(p=>({...p,color:c}))} className={`w-9 h-9 rounded-full border-2 ${brand.color===c?"border-gray-900 scale-110":"border-white"} transition`} style={{background:c}} aria-label={c} />
            ))}
            <input type="color" value={brand.color} onChange={e=>setBrand(p=>({...p,color:e.target.value}))} className="w-9 h-9 rounded-full border border-gray-300" />
          </div>
        </div>
      </div>

      <div className="bg-white border border-gray-200 rounded-2xl p-4 space-y-4 mb-4">
        <p className="sk-display font-semibold text-sm">Marca empleadora (sitio público)</p>
        <Lbl t="Misión / narrativa (header del sitio público)">
          <textarea rows={5} value={brand.mission ?? ""} onChange={e=>setBrand(p=>({...p,mission:e.target.value}))} className={inputCls} />
        </Lbl>
        <Lbl t="¿Por qué unirte a nuestro equipo? (texto editorial)">
          <textarea rows={4} value={brand.whyJoin ?? ""} onChange={e=>setBrand(p=>({...p,whyJoin:e.target.value}))} className={inputCls} />
        </Lbl>
        <div className="grid grid-cols-2 gap-3">
          <Lbl t="Industria"><input value={brand.industry ?? ""} onChange={e=>setBrand(p=>({...p,industry:e.target.value}))} className={inputCls} /></Lbl>
          <Lbl t="Tamaño del equipo"><input value={brand.teamSize ?? ""} onChange={e=>setBrand(p=>({...p,teamSize:e.target.value}))} className={inputCls} /></Lbl>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Lbl t="Sitio web"><input value={brand.website ?? ""} onChange={e=>setBrand(p=>({...p,website:e.target.value}))} className={inputCls} /></Lbl>
          <Lbl t="Ciudad sede"><input value={brand.city ?? ""} onChange={e=>setBrand(p=>({...p,city:e.target.value}))} className={inputCls} /></Lbl>
        </div>
        <Lbl t="Frase del hero (campaña)"><input value={brand.heroPhrase ?? ""} onChange={e=>setBrand(p=>({...p,heroPhrase:e.target.value}))} className={inputCls} /></Lbl>
        <Lbl t="URL de imagen del hero (opcional; si está vacía se usa el fondo editorial)"><input value={brand.heroImageUrl ?? ""} onChange={e=>setBrand(p=>({...p,heroImageUrl:e.target.value}))} className={inputCls} placeholder="https://…" /></Lbl>
        <Lbl t="Beneficios visuales (uno por línea, emoji al inicio)">
          <textarea rows={6} value={(brand.perks ?? []).join("\n")} onChange={e=>setBrand(p=>({...p,perks:e.target.value.split("\n").filter(Boolean)}))} className={inputCls} />
        </Lbl>
        <Lbl t="Lema del footer"><input value={brand.footerTagline ?? ""} onChange={e=>setBrand(p=>({...p,footerTagline:e.target.value}))} className={inputCls} /></Lbl>
      </div>

      <button onClick={()=>{ saveBrand(); notify("Branding guardado · revisa la vista del aspirante"); }} className="bg-[#14181F] text-white rounded-xl px-5 py-2.5 text-sm font-semibold">Guardar branding</button>
      <p className="text-xs text-gray-400 mt-3">El logo, color y textos se reflejan en el enlace público de cada vacante.</p>
    </div>
  );
}
