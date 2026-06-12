"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useSelektor } from "../lib/store";

/* Barra superior de demo: alterna entre la vista pública y el panel interno */
export default function TopBar() {
  const { brand, jobs } = useSelektor();
  const pathname = usePathname();
  const isPanel = pathname.startsWith("/panel");
  const isPublic = !isPanel && pathname !== "/";
  // Si ya estamos en una ruta pública, el enlace la conserva; si no, va a la
  // primera vacante activa de la empresa activa del panel.
  const myJobs = jobs.filter(j => j.companyId === brand.id);
  const publicJob = myJobs.find(j => j.status === "active") ?? myJobs[0];
  const publicHref = isPublic ? pathname : (publicJob ? `/${brand.slug}/${publicJob.slug}` : `/${brand.slug}`);
  const tab = (active) => `px-3 py-1 rounded-full transition ${active ? "bg-white text-[#14181F] font-semibold" : "text-white/70"}`;

  return (
    <div className="bg-[#14181F] text-white px-4 py-2 flex items-center justify-between text-xs">
      <Link href="/" className="sk-display font-semibold tracking-wide text-sm">Selektor</Link>
      <div className="flex gap-1 bg-white/10 rounded-full p-0.5">
        <Link href={publicHref} className={tab(isPublic)}>Vista del aspirante</Link>
        <Link href="/panel" className={tab(isPanel)}>Panel interno</Link>
      </div>
    </div>
  );
}
