"use client";

import { useEffect, useState } from "react";
import { useSelektor } from "../../lib/store";
import BrandHeader from "./BrandHeader";
import BrandFooter from "./BrandFooter";
import JobSidebar from "./JobSidebar";
import JobDetail from "./JobDetail";

/* Experiencia pública unificada de marca empleadora:
   header full-bleed → sidebar de vacantes (izq, sticky) + detalle (der) → footer.
   /[empresa] muestra la primera vacante activa; al elegir otra en el sidebar,
   el panel derecho cambia con fade y la URL se actualiza de forma shallow
   (history.pushState, sin recarga). El deep-link /[empresa]/[vacante] entra
   directo a esa vacante. */
export default function CompanyExperience({ company, initialSlug }) {
  const { jobs } = useSelektor();
  const companyJobs = jobs.filter(j => j.companyId === company.id && j.status !== "archived");
  const openJobs = companyJobs.filter(j => j.status === "active");
  const initial = (initialSlug && companyJobs.find(j => j.slug === initialSlug)) || openJobs[0] || companyJobs[0];
  const [slug, setSlug] = useState(initial?.slug ?? null);
  const job = companyJobs.find(j => j.slug === slug) ?? initial;

  const select = (j) => {
    setSlug(j.slug);
    window.history.pushState({}, "", `/${company.slug}/${j.slug}`);
  };

  // Soporta atrás/adelante del navegador sin recargar
  useEffect(() => {
    const onPop = () => {
      const [emp, vac] = window.location.pathname.split("/").filter(Boolean).map(decodeURIComponent);
      if (emp === company.slug) setSlug(vac ?? (openJobs[0]?.slug ?? null));
    };
    window.addEventListener("popstate", onPop);
    return () => window.removeEventListener("popstate", onPop);
  }, [company.slug]); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <div className="bg-[#FAFAF8] min-h-screen">
      <BrandHeader company={company} />

      <main className="max-w-7xl mx-auto px-5 lg:px-10 pt-8 lg:pt-12">
        {!job ? (
          <p className="text-sm text-gray-500 text-center py-24">Por ahora no hay vacantes publicadas. Vuelve pronto.</p>
        ) : (
          <div className="lg:grid lg:grid-cols-[330px,1fr] lg:gap-12">
            <div className="mb-8 lg:mb-0">
              <JobSidebar company={company} jobs={openJobs} selected={job} onSelect={select} />
            </div>
            <div className="min-w-0">
              <JobDetail company={company} job={job} />
            </div>
          </div>
        )}
      </main>

      <BrandFooter company={company} />
    </div>
  );
}
