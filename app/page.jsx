"use client";

import Link from "next/link";
import { useSelektor } from "../lib/store";

/* Página raíz: acceso al panel interno y a los sitios públicos por empresa */
export default function Home() {
  const { companies, jobs } = useSelektor();
  return (
    <div className="max-w-lg mx-auto px-5 py-12">
      <h1 className="sk-display text-3xl font-bold leading-tight mb-2">Selektor</h1>
      <p className="text-sm text-gray-600 mb-8">Selección de personal multi-empresa. Elige cómo quieres entrar:</p>

      <div className="grid gap-4">
        <Link href="/panel" className="bg-white border border-gray-200 rounded-2xl p-5 hover:border-gray-400 transition block">
          <p className="sk-display font-semibold text-sm mb-1">Panel interno</p>
          <p className="text-xs text-gray-500">Gestiona vacantes, aspirantes, plantillas y correos del proceso.</p>
        </Link>

        {companies.map(co => {
          const n = jobs.filter(j => j.companyId === co.id && j.status === "active").length;
          return (
            <Link key={co.id} href={`/${co.slug}`} className="bg-white border border-gray-200 rounded-2xl p-5 hover:border-gray-400 transition block">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center text-white sk-display font-bold" style={{background:co.color}}>
                  {co.name.split(" ").map(w=>w[0]).join("").slice(0,2)}
                </div>
                <div>
                  <p className="sk-display font-semibold text-sm">{co.name}</p>
                  <p className="text-xs text-gray-500">{co.tagline} · {n} vacante{n===1?"":"s"} activa{n===1?"":"s"}</p>
                </div>
              </div>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
