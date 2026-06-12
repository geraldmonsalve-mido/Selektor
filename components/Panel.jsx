"use client";

import { useState } from "react";
import { useSelektor } from "../lib/store";
import Dashboard from "./Dashboard";
import Jobs from "./Jobs";
import Cands from "./Cands";
import Profile from "./Profile";
import Templates from "./Templates";
import EmailLog from "./EmailLog";
import Config from "./Config";

const NAV = [
  ["dashboard","Inicio"],["jobs","Vacantes"],["cands","Aspirantes"],["templates","Plantillas"],["emails","Correos"],["config","Marca"],
];

/* ================== PANEL INTERNO (opera sobre la empresa activa) ================== */
export default function Panel() {
  const { cands, emails, companies, brand, setActiveCompanyId } = useSelektor();
  const [section, setSection] = useState("dashboard"); // dashboard | jobs | cands | profile | templates | emails | config
  const [profileId, setProfileId] = useState(null);

  const switchCompany = (id) => { setActiveCompanyId(id); setProfileId(null); setSection("dashboard"); };

  return (
    <div className="max-w-5xl mx-auto">
      <div className="flex gap-1 items-center px-3 py-2 overflow-x-auto border-b border-gray-200 bg-white sticky top-0 z-10">
        {NAV.map(([k,l]) => (
          <button key={k} onClick={() => setSection(k)} className={`px-3 py-1.5 rounded-lg text-sm whitespace-nowrap ${section===k||(section==="profile"&&k==="cands")?"bg-[#14181F] text-white font-medium":"text-gray-600"}`}>{l}</button>
        ))}
        <select value={brand.id} onChange={e=>switchCompany(e.target.value)} aria-label="Empresa activa"
          className="ml-auto border border-gray-300 rounded-lg px-2 py-1.5 text-sm bg-white shrink-0">
          {companies.map(co => <option key={co.id} value={co.id}>{co.name}</option>)}
        </select>
      </div>
      <div className="px-4 py-5">
        {section === "dashboard" && <Dashboard setSection={setSection} />}
        {section === "jobs" && <Jobs />}
        {section === "cands" && <Cands setSection={setSection} setProfileId={setProfileId} />}
        {section === "profile" && <Profile setSection={setSection} cand={cands.find(c=>c.id===profileId)} />}
        {section === "templates" && <Templates />}
        {section === "emails" && <EmailLog emails={emails.filter(m => m.companyId === brand.id)} />}
        {section === "config" && <Config />}
      </div>
    </div>
  );
}
