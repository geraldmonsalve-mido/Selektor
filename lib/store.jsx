'use client';

"use client";

import { createContext, useContext, useEffect, useState } from "react";
import { supabase } from "./supabase";
import { TEMPLATES_INIT } from "../data/emailTemplates";
import { COMPANIES_INIT } from "../data/companies";
import { JOBS_INIT } from "../data/jobs";
import { CANDS_INIT, EMAILS_INIT } from "../data/candidates";
import { fill } from "./utils";

const SelektorContext = createContext(null);

/* ---------- Mapeos BD (snake_case) ↔ app (camelCase) ---------- */
const mapCompany = (r) => ({
  id: r.id, name: r.name, slug: r.slug, tagline: r.tagline ?? "", color: r.brand_color, email: r.email,
  city: r.city ?? "", industry: r.industry ?? "", teamSize: r.team_size ?? "", website: r.website ?? "",
  heroImageUrl: r.hero_image_url ?? "", heroPhrase: r.hero_phrase ?? "", mission: r.mission ?? "",
  whyJoin: r.why_join ?? "", perks: r.perks ?? [], footerTagline: r.footer_tagline ?? "",
});

const mapJob = (r) => ({
  id: r.id, companyId: r.company_id, title: r.title, slug: r.slug, city: r.city, country: r.country ?? "",
  modality: r.modality, contract: r.contract, salary: r.salary, status: r.status, description: r.description,
  responsibilities: r.responsibilities ?? [], requirements: r.requirements ?? [], benefits: r.benefits ?? [],
  questions: (r.job_questions ?? [])
    .slice().sort((a, b) => a.position - b.position)
    .map(q => ({ id: q.id, label: q.label, type: q.type, required: q.required, options: q.options ?? [] })),
});

const mapCand = (r) => ({
  id: r.id, jobId: r.job_id, companyId: r.company_id, name: r.name, doc: r.doc, city: r.city, phone: r.phone,
  email: r.email, lastJob: r.last_job, years: Number(r.years), salary: r.salary,
  availability: r.availability, status: r.status, date: r.applied_at, notes: r.notes,
  files: (r.candidate_files ?? []).map(f => f.file_name),
  answers: Object.fromEntries((r.candidate_answers ?? []).map(a => [a.question_id, a.answer])),
});

const mapEmail = (r) => ({
  id: r.id, companyId: r.company_id, to: r.to_email, type: r.template_key, subject: r.subject, body: r.body,
  date: (r.sent_at ?? "").slice(0, 16).replace("T", " "),
});

const mapTemplates = (rows) =>
  Object.fromEntries(rows.map(r => [r.template_key, { name: r.name, subject: r.subject, body: r.body }]));

const warn = (op) => ({ error }) => { if (error) console.warn(`Supabase (${op}):`, error.message); };

/**
 * Estado global multi-empresa. Si Supabase está configurado y el schema
 * "selektor" responde, los datos se leen y persisten allí; si no, opera con
 * los datos en memoria de data/ (modo demo). El panel trabaja sobre la
 * empresa activa (The W por defecto); las rutas públicas resuelven la
 * empresa por slug. Correos y Google Calendar siguen simulados: solo se
 * registran en email_logs / interviews.
 */
export function SelektorProvider({ children }) {
  const [companies, setCompanies] = useState(COMPANIES_INIT);
  const [activeCompanyId, setActiveCompanyId] = useState(COMPANIES_INIT[0].id); // The W
  const [jobs, setJobs] = useState(JOBS_INIT);
  const [cands, setCands] = useState(CANDS_INIT);
  const [templates, setTemplates] = useState(TEMPLATES_INIT);
  const [emails, setEmails] = useState(EMAILS_INIT);
  const [db, setDb] = useState(false); // true = persistencia activa en Supabase
  const [toast, setToast] = useState(null);

  const brand = companies.find(c => c.id === activeCompanyId) ?? companies[0];
  const companyOf = (job) => companies.find(c => c.id === job.companyId) ?? brand;
  const companyBySlug = (slug) => companies.find(c => c.slug === slug);

  useEffect(() => {
    if (!supabase) { console.warn("Supabase sin configurar: usando datos en memoria."); return; }
    (async () => {
      try {
      const [co, jb, cd, tp, em] = await Promise.all([
        supabase.from("companies").select("*").order("created_at"),
        supabase.from("jobs").select("*, job_questions(*)").order("created_at"),
        supabase.from("candidates").select("*, candidate_answers(*), candidate_files(*)").order("created_at", { ascending: false }),
        supabase.from("email_templates").select("*"),
        supabase.from("email_logs").select("*").order("sent_at", { ascending: false }),
      ]);
      console.log("companies", co.error, co.data?.length);
      console.log("jobs", jb.error, jb.data?.length);
      console.log("candidates", cd.error, cd.data?.length);
      console.log("templates", tp.error, tp.data?.length);
      console.log("emails", em.error, em.data?.length);

      const error = co.error || jb.error || cd.error || tp.error || em.error;
      if (error || !co.data?.length) {
        console.warn("Supabase no disponible (¿migraciones ejecutadas y schema expuesto?). Usando datos en memoria.", error?.message ?? "");
        return;
      }
      const active = co.data.find(r => r.slug === "thew") ?? co.data[0];
      // Plantillas de la empresa activa; si aún no tiene, las primeras disponibles
      const mine = tp.data.filter(r => r.company_id === active.id);
      setCompanies(co.data.map(mapCompany));
      setActiveCompanyId(active.id);
      setJobs(jb.data.map(mapJob));
      setCands(cd.data.map(mapCand));
      setTemplates(mapTemplates(mine.length ? mine : tp.data));
      setEmails(em.data.map(mapEmail));
      setDb(true);
      console.log("✅ DB MODE ACTIVADO");
      } catch (e) {
        console.error("🔥 ERROR EN useEffect:", e);
      }
    })();
  }, []);

  const notify = (m) => { setToast(m); setTimeout(() => setToast(null), 2600); };

  /* Edita la empresa activa (Config del panel) */
  const setBrand = (updater) =>
    setCompanies(list => list.map(c => c.id === brand.id ? (typeof updater === "function" ? updater(c) : updater) : c));

  const sendEmail = (type, cand, job, extra = {}) => {
    const t = templates[type];
    const company = companyOf(job);
    const vars = { nombre: cand.name.split(" ")[0], empresa: company.name, cargo: job.title, ...extra };
    const mail = { id: Date.now() + Math.random(), companyId: company.id, to: cand.email, type, subject: fill(t.subject, vars), body: fill(t.body, vars), date: new Date().toISOString().slice(0,16).replace("T"," ") };
    setEmails(p => [mail, ...p]);
    if (db) supabase.from("email_logs").insert({
      company_id: company.id, candidate_id: typeof cand.id === "string" ? cand.id : null,
      template_key: type, to_email: mail.to, subject: mail.subject, body: mail.body,
    }).then(warn("email_logs"));
    return mail;
  };

  const setStatus = (cand, status, emailType) => {
    setCands(p => p.map(c => c.id === cand.id ? { ...c, status } : c));
    if (db) supabase.from("candidates").update({ status }).eq("id", cand.id).then(warn("candidates.status"));
    const job = jobs.find(j => j.id === cand.jobId);
    if (emailType) { sendEmail(emailType, cand, job); notify(`Estado actualizado y correo enviado a ${cand.name.split(" ")[0]}`); }
    else notify("Estado actualizado");
  };

  const selectFinal = (cand) => {
    const job = jobs.find(j => j.id === cand.jobId);
    setCands(p => p.map(c => c.id === cand.id ? { ...c, status:"selected" } : c));
    setJobs(p => p.map(j => j.id === job.id ? { ...j, status:"closed" } : j));
    if (db) {
      supabase.from("candidates").update({ status: "selected" }).eq("id", cand.id).then(warn("candidates.selected"));
      supabase.from("jobs").update({ status: "closed" }).eq("id", job.id).then(warn("jobs.closed"));
    }
    sendEmail("selected", cand, job);
    cands.filter(c => c.jobId === job.id && c.id !== cand.id && !["rejected","selected"].includes(c.status))
      .forEach(c => sendEmail("job_closed", c, job));
    notify(`${cand.name.split(" ")[0]} seleccionado · vacante cerrada · correos enviados`);
  };

  const addCandidate = async (job, data) => {
    const nc = { id: Date.now(), jobId: job.id, companyId: job.companyId, status:"reviewing", date: new Date().toISOString().slice(0,10), notes:"", ...data, years: data.years || 0 };
    setCands(p => [nc, ...p]);
    if (db) {
      const { data: row, error } = await supabase.from("candidates").insert({
        job_id: job.id, company_id: job.companyId, name: data.name, doc: data.doc, city: data.city,
        phone: data.phone, email: data.email, last_job: data.lastJob,
        years: Number(data.years) || 0, salary: data.salary, availability: data.availability,
        status: "reviewing",
      }).select().single();
      if (error) { console.warn("Supabase (candidates.insert):", error.message); }
      else {
        // Reemplaza el id temporal por el uuid real para que las acciones del panel persistan
        setCands(p => p.map(c => c.id === nc.id ? { ...c, id: row.id } : c));
        nc.id = row.id;
        const answers = Object.entries(data.answers ?? {}).map(([qid, answer]) => ({ candidate_id: row.id, question_id: qid, answer: Array.isArray(answer) ? answer.join(", ") : String(answer) }));
        if (answers.length) supabase.from("candidate_answers").insert(answers).then(warn("candidate_answers"));
        const files = (data.files ?? []).map(name => ({ candidate_id: row.id, file_name: name }));
        if (files.length) supabase.from("candidate_files").insert(files).then(warn("candidate_files"));
      }
    }
    sendEmail("application_received", nc, job);
  };

  const scheduleInterview = (cand, job, d) => {
    if (db) supabase.from("interviews").insert({
      company_id: job.companyId, candidate_id: cand.id, job_id: job.id,
      date: d.date, start_time: d.start, end_time: d.end,
      modality: d.modality, place: d.place, recruiter: d.recruiter, notes: d.notes ?? "",
    }).then(warn("interviews"));
    sendEmail("interview_invitation", cand, job, {
      fecha_entrevista: d.date, hora_entrevista: `${d.start} – ${d.end}`,
      modalidad: d.modality, ubicacion_o_link: d.place, nombre_reclutador: d.recruiter,
    });
    setStatus(cand, "interview_scheduled");
    notify("Evento creado en Google Calendar y correo enviado");
  };

  /**
   * Crea o actualiza una vacante con sus preguntas. En modo BD sincroniza
   * job_questions por diff (update/insert/delete) para conservar los ids y
   * no romper el vínculo de respuestas existentes. Devuelve la vacante
   * guardada o null si falló.
   */
  const saveJob = async (data) => {
    const isNew = !data.id;
    const { questions, ...fields } = data;

    if (!db) {
      const jobId = data.id ?? Date.now();
      const qs = questions.map((q, i) => ({ ...q, id: q.id && !String(q.id).startsWith("tmp-") ? q.id : `q-${Date.now()}-${i}` }));
      const job = { ...fields, id: jobId, questions: qs };
      setJobs(p => isNew ? [...p, job] : p.map(j => j.id === jobId ? job : j));
      notify(isNew ? "Vacante creada" : "Vacante actualizada");
      return job;
    }

    const row = {
      company_id: fields.companyId, title: fields.title, slug: fields.slug, city: fields.city,
      country: fields.country, modality: fields.modality, contract: fields.contract,
      salary: fields.salary, status: fields.status, description: fields.description,
      responsibilities: fields.responsibilities, requirements: fields.requirements, benefits: fields.benefits,
    };
    let jobId = data.id;
    if (isNew) {
      const { data: created, error } = await supabase.from("jobs").insert(row).select().single();
      if (error) { console.warn("Supabase (jobs.insert):", error.message); notify("Error al guardar la vacante"); return null; }
      jobId = created.id;
    } else {
      const { error } = await supabase.from("jobs").update(row).eq("id", jobId);
      if (error) { console.warn("Supabase (jobs.update):", error.message); notify("Error al guardar la vacante"); return null; }
    }

    // Diff de preguntas: conserva ids existentes, inserta nuevas, borra removidas
    const prev = isNew ? [] : (jobs.find(j => j.id === jobId)?.questions ?? []);
    const isReal = (q) => q.id && !String(q.id).startsWith("tmp-");
    const keepIds = new Set(questions.filter(isReal).map(q => q.id));
    const removed = prev.filter(q => !keepIds.has(q.id)).map(q => q.id);
    if (removed.length) {
      const { error } = await supabase.from("job_questions").delete().in("id", removed);
      if (error) console.warn("Supabase (job_questions.delete):", error.message);
    }
    for (let i = 0; i < questions.length; i++) {
      const q = questions[i];
      const body = { job_id: jobId, label: q.label, type: q.type, required: q.required, options: q.options ?? [], position: i + 1 };
      const { error } = isReal(q)
        ? await supabase.from("job_questions").update(body).eq("id", q.id)
        : await supabase.from("job_questions").insert(body);
      if (error) console.warn("Supabase (job_questions.save):", error.message);
    }

    const { data: fresh, error: freshErr } = await supabase.from("jobs").select("*, job_questions(*)").eq("id", jobId).single();
    if (freshErr || !fresh) { console.warn("Supabase (jobs.refetch):", freshErr?.message); notify("Vacante guardada (recarga para ver cambios)"); return null; }
    const mapped = mapJob(fresh);
    setJobs(p => isNew ? [...p, mapped] : p.map(j => j.id === jobId ? mapped : j));
    notify(isNew ? "Vacante creada y publicada" : "Vacante actualizada y publicada");
    return mapped;
  };

  /**
   * Suscripción Realtime a los cambios de vacantes de una empresa
   * (postgres_changes sobre selektor.jobs). Devuelve la función de limpieza.
   * En modo memoria no hace nada.
   */
  const subscribeCompanyJobs = (companyId) => {
    if (!db || !supabase) return () => {};
    const channel = supabase.channel(`selektor-jobs-${companyId}`)
      .on("postgres_changes",
        { event: "*", schema: "selektor", table: "jobs", filter: `company_id=eq.${companyId}` },
        async (payload) => {
          if (payload.eventType === "DELETE") { setJobs(p => p.filter(j => j.id !== payload.old?.id)); return; }
          const jobId = payload.new?.id;
          if (!jobId) return;
          const { data: row, error } = await supabase.from("jobs").select("*, job_questions(*)").eq("id", jobId).single();
          if (error || !row) return;
          const mapped = mapJob(row);
          setJobs(p => p.some(j => j.id === jobId) ? p.map(j => j.id === jobId ? mapped : j) : [...p, mapped]);
        })
      .subscribe();
    return () => { supabase.removeChannel(channel); };
  };

  const saveTemplate = (key) => {
    const t = templates[key];
    if (db) supabase.from("email_templates").update({ subject: t.subject, body: t.body })
      .eq("company_id", brand.id).eq("template_key", key).then(warn("email_templates"));
  };

  const saveBrand = () => {
    if (db) supabase.from("companies").update({
      name: brand.name, slug: brand.slug, brand_color: brand.color, tagline: brand.tagline,
      city: brand.city, industry: brand.industry, team_size: brand.teamSize, website: brand.website,
      hero_image_url: brand.heroImageUrl, hero_phrase: brand.heroPhrase, mission: brand.mission,
      why_join: brand.whyJoin, perks: brand.perks, footer_tagline: brand.footerTagline,
    }).eq("id", brand.id).then(warn("companies"));
  };

  const value = {
    companies, activeCompanyId, setActiveCompanyId, companyBySlug, dbMode: db,
    brand, setBrand, jobs, setJobs, cands, setCands, templates, setTemplates, emails,
    notify, sendEmail, setStatus, selectFinal, addCandidate, scheduleInterview,
    saveJob, subscribeCompanyJobs, saveTemplate, saveBrand,
  };

  return (
    <SelektorContext.Provider value={value}>
      {children}
      {toast && <div className="fixed bottom-4 left-1/2 -translate-x-1/2 bg-[#14181F] text-white text-sm px-4 py-2.5 rounded-xl shadow-xl z-50">{toast}</div>}
    </SelektorContext.Provider>
  );
}

export const useSelektor = () => useContext(SelektorContext);
