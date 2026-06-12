"use client";

import { useSelektor } from "../../../lib/store";
import CompanyExperience from "../../../components/public/CompanyExperience";

/* Deep-link público: selektor.app/[empresa]/[vacante]
   Entra a la experiencia de la empresa con esa vacante seleccionada. */
export default function PublicJobPage({ params }) {
  const { companyBySlug, jobs } = useSelektor();
  const company = companyBySlug(decodeURIComponent(params.empresa));
  const slug = decodeURIComponent(params.vacante);
  const job = company && jobs.find(j => j.companyId === company.id && j.slug === slug);

  if (!company) return (
    <div className="max-w-lg mx-auto px-6 py-20 text-center">
      <h1 className="sk-display text-2xl font-bold mb-2">Empresa no encontrada</h1>
      <p className="text-sm text-gray-500">El enlace no corresponde a ninguna empresa registrada. Verifica la dirección.</p>
    </div>
  );

  if (!job) return (
    <div className="max-w-lg mx-auto px-6 py-20 text-center">
      <h1 className="sk-display text-2xl font-bold mb-2">Vacante no encontrada</h1>
      <p className="text-sm text-gray-500">El enlace no corresponde a ninguna vacante de {company.name}. Verifica la dirección o contacta a la empresa.</p>
    </div>
  );

  return <CompanyExperience company={company} initialSlug={slug} />;
}
