"use client";

/* Header de marca full-bleed: narrativa editorial sobre negro profundo */
export default function BrandHeader({ company }) {
  const meta = [
    company.city && ["📍", company.city],
    company.industry && ["🧵", company.industry],
    company.teamSize && ["👥", company.teamSize],
    company.website && ["🌐", company.website],
  ].filter(Boolean);

  return (
    <header className="bg-[#0B0B0B] text-white">
      <div className="max-w-7xl mx-auto px-5 lg:px-10 pt-14 pb-12 lg:pt-24 lg:pb-20">
        <div className="flex items-center gap-3 mb-8 anim-rise">
          <div className="w-11 h-11 rounded-xl flex items-center justify-center sk-display font-bold text-base text-white ring-1 ring-white/15" style={{background:"rgba(255,255,255,0.06)"}}>
            {company.name.split(" ").map(w=>w[0]).join("").slice(0,2)}
          </div>
          <span className="text-[11px] uppercase tracking-[0.25em] text-white/50">Trabaja con nosotros</span>
        </div>

        <h1 className="sk-display font-bold tracking-tight leading-[0.95] text-5xl lg:text-7xl mb-7 anim-rise anim-rise-1">
          {company.name}
        </h1>

        {company.mission && (
          <p className="text-sm lg:text-base leading-relaxed text-white/65 max-w-3xl mb-9 anim-rise anim-rise-2">
            {company.mission}
          </p>
        )}

        {meta.length > 0 && (
          <div className="flex flex-wrap gap-x-7 gap-y-2.5 anim-rise anim-rise-3">
            {meta.map(([icon, label]) => (
              <span key={label} className="inline-flex items-center gap-2 text-[11px] uppercase tracking-[0.18em] text-white/45">
                <span className="text-sm leading-none">{icon}</span>{label}
              </span>
            ))}
          </div>
        )}
      </div>
    </header>
  );
}
