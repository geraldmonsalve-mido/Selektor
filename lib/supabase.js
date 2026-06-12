import { createClient } from "@supabase/supabase-js";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

/** true si .env.local tiene las credenciales públicas configuradas */
export const isSupabaseConfigured = Boolean(url && anonKey);

/** Cliente de Supabase apuntando al schema aislado "selektor" (nunca public). */
export const supabase = isSupabaseConfigured
  ? createClient(url, anonKey, { db: { schema: "selektor" } })
  : null;
