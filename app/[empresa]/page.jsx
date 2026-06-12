"use client";

import { useSelektor } from "../../lib/store";
import CompanyExperience from "../../components/public/CompanyExperience";

/* Experiencia pública de empresa: selektor.app/[empresa]
   Muestra la primera vacante activa seleccionada por defecto. */
export default function CompanyPage({ params }) {
  const { companyBySlug } = useSelektor();
  const company = companyBySlug(decodeURIComponent(params.empresa));

  if (!company) return (
    <div className="max-w-lg mx-auto px-6 py-20 text-center">
      <h1 className="sk-display text-2xl font-bold mb-2">Empresa no encontrada</h1>
      <p className="text-sm text-gray-500">El enlace no corresponde a ninguna empresa registrada. Verifica la dirección.</p>
    </div>
  );

  return <CompanyExperience company={company} />;
}
