"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useSelektor } from "../lib/store";
import JobEditor from "./panel/JobEditor";

export default function Jobs() {
  const { jobs, cands, brand, notify } = useSelektor();
  const router = useRouter();

  const [editingJob, setEditingJob] = useState(null);
  const [open, setOpen] = useState(false);

  const myJobs = jobs.filter(j => j.companyId === brand.id);

  const copyLink = async (job) => {
    const url = `${window.location.origin}/${brand.slug}/${job.slug}`;
    try {
      await navigator.clipboard.writeText(url);
      notify("Enlace copiado al portapapeles");
    } catch {
      notify("No fue posible copiar el enlace");
    }
  };

  const badge = (status) => {
    switch (status) {
      case "active":
        return "bg-emerald-50 text-emerald-700";
      case "paused":
        return "bg-amber-50 text-amber-700";
      case "closed":
        return "bg-red-50 text-red-700";
      default:
        return "bg-zinc-100 text-zinc-600";
    }
  };

  const label = (status) => {
    switch (status) {
      case "active":
        return "Activa";
      case "paused":
        return "Pausada";
      case "closed":
        return "Cerrada";
      default:
        return status;
    }
  };

  return (
    <>
      {open && (
        <JobEditor
          job={editingJob}
          onClose={() => {
            setEditingJob(null);
            setOpen(false);
          }}
        />
      )}

      <div className="space-y-5">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="sk-display text-2xl font-bold">
              Vacantes · {brand.name}
            </h1>
            <p className="text-sm text-gray-500 mt-1">
              Administra las oportunidades laborales publicadas.
            </p>
          </div>

          <button
            onClick={() => {
              setEditingJob(null);
              setOpen(true);
            }}
            className="rounded-xl bg-black text-white px-4 py-2 text-sm hover:opacity-90"
          >
            + Nueva vacante
          </button>
        </div>

        <div className="space-y-4">
          {myJobs.map((j) => (
            <div
              key={j.id}
              className="rounded-2xl border border-zinc-200 bg-white p-5"
            >
              <div className="flex items-start justify-between gap-4">
                <div>
                  <h3 className="font-semibold text-lg">{j.title}</h3>

                  <p className="text-sm text-zinc-500 mt-1">
                    {j.city} · {j.country || "Colombia"} · {j.modality}
                  </p>

                  <p className="text-xs text-zinc-400 mt-2 break-all">
                    /{brand.slug}/{j.slug}
                  </p>

                  <p className="text-xs text-zinc-500 mt-2">
                    {cands.filter(c => c.jobId === j.id).length} aspirantes
                  </p>
                </div>

                <span
                  className={`rounded-full px-3 py-1 text-xs font-medium ${badge(j.status)}`}
                >
                  {label(j.status)}
                </span>
              </div>

              <div className="flex flex-wrap gap-2 mt-5">
                <button
                  onClick={() => copyLink(j)}
                  className="rounded-lg border px-3 py-1.5 text-xs"
                >
                  Copiar enlace
                </button>

                <button
                  onClick={() => window.open(`/${brand.slug}/${j.slug}`, "_blank")}
                  className="rounded-lg border px-3 py-1.5 text-xs"
                >
                  Vista previa
                </button>

                <button
                  onClick={() => {
                    setEditingJob(j);
                    setOpen(true);
                  }}
                  className="rounded-lg border px-3 py-1.5 text-xs"
                >
                  Editar
                </button>

                <button
                  onClick={() => router.push(`/${brand.slug}/${j.slug}`)}
                  className="rounded-lg border px-3 py-1.5 text-xs"
                >
                  Ver como aspirante
                </button>
              </div>
            </div>
          ))}

          {!myJobs.length && (
            <div className="rounded-2xl border border-dashed border-zinc-300 bg-zinc-50 p-10 text-center">
              <p className="font-medium">Aún no hay vacantes creadas.</p>
              <p className="text-sm text-zinc-500 mt-1">
                Haz clic en “Nueva vacante” para comenzar.
              </p>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
