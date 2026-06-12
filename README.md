# Selektor — prototipo local

## Requisitos
- Node.js 18 o superior

## Correr en localhost
```bash
npm install
npm run dev
```
Abrir http://localhost:3000

## Estructura
- `app/` — App Router de Next.js (layout y página principal)
- `components/Selektor.jsx` — toda la app del prototipo (vista pública + panel)

## Próximos pasos (según especificación)
- Conectar Supabase (Postgres + Storage) para vacantes, candidatos y archivos
- Resend para correos transaccionales reales
- Google Calendar API para entrevistas
- Rutas públicas dinámicas: /[empresa]/[vacante]
