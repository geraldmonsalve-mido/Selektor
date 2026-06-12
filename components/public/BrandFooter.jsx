"use client";

/* Footer editorial */
export default function BrandFooter({ company }) {
  return (
    <footer className="bg-[#0B0B0B] text-white mt-20">
      <div className="max-w-7xl mx-auto px-5 lg:px-10 py-14 lg:py-16">
        <p className="sk-display font-bold text-2xl tracking-tight mb-2">{company.name}</p>
        {company.footerTagline && (
          <p className="text-sm text-white/55 max-w-md leading-relaxed mb-8">{company.footerTagline}</p>
        )}
        <div className="flex flex-wrap items-center gap-x-6 gap-y-2 text-[11px] uppercase tracking-[0.18em] text-white/40 mb-10">
          <a href="#" className="hover:text-white/80 transition-colors">Instagram</a>
          <a href="#" className="hover:text-white/80 transition-colors">TikTok</a>
          <a href="#" className="hover:text-white/80 transition-colors">LinkedIn</a>
          {company.website && <span className="text-white/60">{company.website}</span>}
        </div>
        <div className="border-t border-white/10 pt-6 flex flex-wrap justify-between gap-2 text-[11px] text-white/35">
          <span>© 2026 {company.name}. Todos los derechos reservados.</span>
          <span>Proceso gestionado con Selektor · Política de Tratamiento de Datos</span>
        </div>
      </div>
    </footer>
  );
}
