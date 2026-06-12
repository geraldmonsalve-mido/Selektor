"use client";

import { useEffect, useMemo, useState } from "react";
import { useSelektor } from "../../lib/store";
import { slugify } from "../../lib/utils";

const QUESTION_TYPES = [
  ["short_text", "Texto corto"],
  ["long_text", "Texto largo"],
  ["single_choice", "Selección única"],
  ["multiple_choice", "Selección múltiple"],
  ["yes_no", "Sí / No"],
  ["number", "Número"],
  ["date", "Fecha"],
  ["file", "Archivo"],
];

const emptyJob = (companyId) => ({
  companyId,
  title: "",
  slug: "",
  city: "Medellín",
  country: "Colombia",
  modality: "Presencial",
  contract: "Tiempo completo",
  salary: "A convenir",
  status: "active",
  description: "",
  responsibilities: [""],
  requirements: [""],
  benefits: [""],
  questions: [],
});

function cleanList(list) {
  return (list ?? []).map(x => String(x).trim()).filter(Boolean);
}

function ListEditor({ title, items, setItems, placeholder }) {
  const move = (i, dir) => {
    const arr = [...items];
    const j = i + dir;
    if (j < 0 || j >= arr.length) return;
    [arr[i], arr[j]] = [arr[j], arr[i]];
    setItems(arr);
  };

  return (
    <div className="rounded-2xl border border-zinc-200 bg-white p-4">
      <div className="flex items-center justify-between mb-3">
        <h3 className="font-semibold text-zinc-900">{title}</h3>
        <button
          type="button"
          onClick={() => setItems([...(items ?? []), ""])}
          className="text-sm px-3 py-1.5 rounded-lg bg-zinc-900 text-white"
        >
          Agregar
        </button>
      </div>

      <div className="space-y-2">
        {(items ?? []).map((item, i) => (
          <div key={i} className="flex gap-2">
            <input
              value={item}
              onChange={(e) => {
                const arr = [...items];
                arr[i] = e.target.value;
                setItems(arr);
              }}
              placeholder={placeholder}
              className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900"
            />
            <button type="button" onClick={() => move(i, -1)} className="px-2 rounded-lg border">↑</button>
            <button type="button" onClick={() => move(i, 1)} className="px-2 rounded-lg border">↓</button>
            <button
              type="button"
              onClick={() => setItems(items.filter((_, idx) => idx !== i))}
              className="px-3 rounded-lg border text-red-600"
            >
              ×
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

function QuestionBuilder({ questions, setQuestions }) {
  const addQuestion = () => {
    setQuestions([
      ...questions,
      {
        id: `tmp-${Date.now()}`,
        label: "",
        type: "short_text",
        required: false,
        options: [],
      },
    ]);
  };

  const update = (i, patch) => {
    const arr = [...questions];
    arr[i] = { ...arr[i], ...patch };
    setQuestions(arr);
  };

  const move = (i, dir) => {
    const arr = [...questions];
    const j = i + dir;
    if (j < 0 || j >= arr.length) return;
    [arr[i], arr[j]] = [arr[j], arr[i]];
    setQuestions(arr);
  };

  return (
    <div className="rounded-2xl border border-zinc-200 bg-white p-4">
      <div className="flex items-center justify-between mb-3">
        <div>
          <h3 className="font-semibold text-zinc-900">Preguntas personalizadas</h3>
          <p className="text-sm text-zinc-500">Crea preguntas adicionales para esta vacante.</p>
        </div>
        <button type="button" onClick={addQuestion} className="text-sm px-3 py-1.5 rounded-lg bg-zinc-900 text-white">
          Agregar pregunta
        </button>
      </div>

      <div className="space-y-3">
        {questions.map((q, i) => {
          const hasOptions = ["single_choice", "multiple_choice"].includes(q.type);

          return (
            <div key={q.id} className="rounded-xl border border-zinc-200 p-3 space-y-3">
              <div className="grid grid-cols-1 md:grid-cols-[1fr_190px_auto] gap-2">
                <input
                  value={q.label}
                  onChange={(e) => update(i, { label: e.target.value })}
                  placeholder="Pregunta"
                  className="rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900"
                />

                <select
                  value={q.type}
                  onChange={(e) => update(i, { type: e.target.value, options: [] })}
                  className="rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900"
                >
                  {QUESTION_TYPES.map(([value, label]) => (
                    <option key={value} value={value}>{label}</option>
                  ))}
                </select>

                <div className="flex gap-2">
                  <button type="button" onClick={() => move(i, -1)} className="px-2 rounded-lg border">↑</button>
                  <button type="button" onClick={() => move(i, 1)} className="px-2 rounded-lg border">↓</button>
                  <button
                    type="button"
                    onClick={() => setQuestions(questions.filter((_, idx) => idx !== i))}
                    className="px-3 rounded-lg border text-red-600"
                  >
                    ×
                  </button>
                </div>
              </div>

              <label className="inline-flex items-center gap-2 text-sm text-zinc-700">
                <input
                  type="checkbox"
                  checked={!!q.required}
                  onChange={(e) => update(i, { required: e.target.checked })}
                />
                Obligatoria
              </label>

              {hasOptions && (
                <div>
                  <label className="text-sm font-medium text-zinc-700">Opciones</label>
                  <textarea
                    value={(q.options ?? []).join("\n")}
                    onChange={(e) => update(i, {
                      options: e.target.value.split("\n").map(x => x.trim()).filter(Boolean),
                    })}
                    placeholder={"Una opción por línea\nEj: Básico\nIntermedio\nAvanzado"}
                    className="mt-1 w-full min-h-24 rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900"
                  />
                </div>
              )}
            </div>
          );
        })}

        {!questions.length && (
          <div className="rounded-xl bg-zinc-50 p-4 text-sm text-zinc-500">
            Aún no has agregado preguntas personalizadas.
          </div>
        )}
      </div>
    </div>
  );
}

export default function JobEditor({ job, onClose }) {
  const { brand, companies, activeCompanyId, jobs, saveJob } = useSelektor();
  const [form, setForm] = useState(() => job ? structuredClone(job) : emptyJob(activeCompanyId || brand?.id || companies?.[0]?.id));
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!form.companyId && (activeCompanyId || brand?.id || companies?.[0]?.id)) {
      setForm(prev => ({
        ...prev,
        companyId: prev.companyId || activeCompanyId || brand?.id || companies?.[0]?.id,
      }));
    }
  }, [activeCompanyId, brand, companies]);


  const publicUrl = useMemo(() => {
    if (!form.slug) return `/${brand.slug}`;
    return `/${brand.slug}/${form.slug}`;
  }, [brand.slug, form.slug]);

  const patch = (data) => setForm(prev => ({ ...prev, ...data }));

  const onTitleChange = (title) => {
    const shouldAutoSlug = !form.id || !form.slug || form.slug === slugify(form.title);
    patch({
      title,
      slug: shouldAutoSlug ? slugify(title) : form.slug,
    });
  };

  const validate = () => {
    const title = form.title.trim();
    const description = form.description.trim();
    const slug = slugify(form.slug);

    if (!title) return "El título es obligatorio.";
    if (!description) return "La descripción es obligatoria.";
    if (!slug) return "El slug es obligatorio.";

    const duplicated = jobs.some(j =>
      j.companyId === form.companyId &&
      j.id !== form.id &&
      j.slug === slug
    );

    if (duplicated) return "Ya existe una vacante con ese slug en esta empresa.";

    return "";
  };

  const submit = async (e) => {
    e.preventDefault();
    setError("");

    const message = validate();
    if (message) {
      setError(message);
      return;
    }

    setSaving(true);

    const payload = {
      companyId: form.companyId || activeCompanyId || brand?.id || companies?.[0]?.id,
      ...form,
      title: form.title.trim(),
      slug: slugify(form.slug),
      city: form.city.trim(),
      country: form.country.trim(),
      salary: form.salary.trim() || "A convenir",
      description: form.description.trim(),
      responsibilities: cleanList(form.responsibilities),
      requirements: cleanList(form.requirements),
      benefits: cleanList(form.benefits),
      questions: (form.questions ?? [])
        .map(q => ({
          ...q,
          label: String(q.label ?? "").trim(),
          options: q.options ?? [],
        }))
        .filter(q => q.label),
    };

    const saved = await saveJob(payload);
    setSaving(false);

    if (saved && onClose) onClose();
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm overflow-y-auto">
      <div className="min-h-screen p-4 md:p-8">
        <form onSubmit={submit} className="mx-auto max-w-6xl rounded-3xl bg-zinc-50 shadow-2xl overflow-hidden">
          <div className="sticky top-0 z-10 bg-white border-b border-zinc-200 px-5 md:px-8 py-4 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
            <div>
              <p className="text-xs uppercase tracking-[0.22em] text-zinc-400">Editor de vacante</p>
              <h2 className="text-2xl font-bold text-zinc-950">
                {form.id ? "Editar vacante" : "Nueva vacante"}
              </h2>
            </div>

            <div className="flex flex-wrap gap-2">
              <a
                href={publicUrl}
                target="_blank"
                className="px-4 py-2 rounded-xl border border-zinc-200 text-sm bg-white hover:bg-zinc-50"
              >
                Vista previa
              </a>
              <button type="button" onClick={onClose} className="px-4 py-2 rounded-xl border border-zinc-200 text-sm bg-white">
                Cancelar
              </button>
              <button disabled={saving} className="px-5 py-2 rounded-xl bg-zinc-950 text-white text-sm disabled:opacity-50">
                {saving ? "Guardando..." : "Guardar y publicar"}
              </button>
            </div>
          </div>

          <div className="p-5 md:p-8 space-y-5">
            {error && (
              <div className="rounded-xl bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
                {error}
              </div>
            )}

            <div className="rounded-2xl border border-zinc-200 bg-white p-4 grid grid-cols-1 md:grid-cols-2 gap-4">
              <label className="space-y-1">
                <span className="text-sm font-medium">Título</span>
                <input value={form.title} onChange={(e) => onTitleChange(e.target.value)} className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900" />
              </label>

              <label className="space-y-1">
                <span className="text-sm font-medium">Slug público</span>
                <input value={form.slug} onChange={(e) => patch({ slug: slugify(e.target.value) })} className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900" />
              </label>

              <label className="space-y-1">
                <span className="text-sm font-medium">Ciudad</span>
                <input value={form.city} onChange={(e) => patch({ city: e.target.value })} className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900" />
              </label>

              <label className="space-y-1">
                <span className="text-sm font-medium">País</span>
                <input value={form.country} onChange={(e) => patch({ country: e.target.value })} className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900" />
              </label>

              <label className="space-y-1">
                <span className="text-sm font-medium">Modalidad</span>
                <select value={form.modality} onChange={(e) => patch({ modality: e.target.value })} className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm">
                  <option>Presencial</option>
                  <option>Remoto</option>
                  <option>Híbrido</option>
                </select>
              </label>

              <label className="space-y-1">
                <span className="text-sm font-medium">Tipo de contrato</span>
                <input value={form.contract} onChange={(e) => patch({ contract: e.target.value })} className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900" />
              </label>

              <label className="space-y-1">
                <span className="text-sm font-medium">Rango salarial</span>
                <input value={form.salary} onChange={(e) => patch({ salary: e.target.value })} className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900" />
              </label>

              <label className="space-y-1">
                <span className="text-sm font-medium">Estado</span>
                <select value={form.status} onChange={(e) => patch({ status: e.target.value })} className="w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm">
                  <option value="active">Activa</option>
                  <option value="paused">Pausada</option>
                  <option value="closed">Cerrada</option>
                </select>
              </label>

              <label className="space-y-1 md:col-span-2">
                <span className="text-sm font-medium">Descripción</span>
                <textarea value={form.description} onChange={(e) => patch({ description: e.target.value })} className="w-full min-h-32 rounded-xl border border-zinc-200 px-3 py-2 text-sm outline-none focus:border-zinc-900" />
              </label>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
              <ListEditor title="Responsabilidades" items={form.responsibilities} setItems={(v) => patch({ responsibilities: v })} placeholder="Ej: Atender clientes de manera personalizada" />
              <ListEditor title="Requisitos" items={form.requirements} setItems={(v) => patch({ requirements: v })} placeholder="Ej: Experiencia mínima de 1 año" />
              <ListEditor title="Beneficios" items={form.benefits} setItems={(v) => patch({ benefits: v })} placeholder="Ej: Descuentos en productos de la marca" />
            </div>

            <QuestionBuilder questions={form.questions ?? []} setQuestions={(v) => patch({ questions: v })} />
          </div>
        </form>
      </div>
    </div>
  );
}
