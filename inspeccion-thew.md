# Inspección SOLO LECTURA — Proyecto Supabase compartido con "The W"

Proyecto: `eafaldhtcebaiujftqei` · https://eafaldhtcebaiujftqei.supabase.co
Fecha: 2026-06-11

## 1. Lo que se pudo verificar sin acceso SQL

Sin CLI logueado, sin psql y sin service_role key, la inspección remota quedó limitada
a la API REST con la anon key:

| Verificación | Resultado | Lectura |
|---|---|---|
| `GET /rest/v1/` (spec OpenAPI del schema expuesto) | `Invalid API key — Only the service_role API key can be used for this endpoint` | El proyecto restringe la introspección del API al service_role. Buena postura de seguridad; no fue posible listar las tablas de The W desde fuera. |
| `GET /storage/v1/bucket` como anon | `[]` | El rol anon no ve ningún bucket. Los buckets de The W (si existen) no son visibles públicamente. |

**Conclusión operativa:** no fue posible enumerar los objetos de The W desde aquí.
Las migraciones de Selektor se diseñaron para NO depender de ese conocimiento:
todo vive en el schema nuevo `selektor`, con `IF NOT EXISTS`, sin ningún
`DROP/TRUNCATE/DELETE/ALTER/UPDATE` sobre objetos existentes y sin tocar `public`.

## 2. Consultas de inspección para ejecutar en el SQL Editor (solo lectura)

Ejecuta estas consultas en el dashboard (SQL Editor) **antes** de las migraciones
y pega los resultados en las secciones de abajo. Ninguna modifica nada.

```sql
-- 2.1 Schemas existentes
SELECT schema_name FROM information_schema.schemata
WHERE schema_name NOT IN ('pg_catalog','information_schema','pg_toast')
ORDER BY 1;

-- 2.2 Tablas por schema (las de The W deberían estar en public)
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog','information_schema','pg_toast')
ORDER BY 1, 2;

-- 2.3 Columnas de las tablas de public
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 2.4 Políticas RLS existentes
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies
ORDER BY schemaname, tablename, policyname;

-- 2.5 Funciones definidas por usuario
SELECT n.nspname AS schema, p.proname AS funcion
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname NOT IN ('pg_catalog','information_schema','extensions','graphql','graphql_public','pgbouncer','realtime','supabase_functions','vault','storage','auth')
ORDER BY 1, 2;

-- 2.6 Triggers
SELECT event_object_schema, event_object_table, trigger_name, action_timing, event_manipulation
FROM information_schema.triggers
WHERE event_object_schema NOT IN ('pg_catalog','information_schema')
ORDER BY 1, 2, 3;

-- 2.7 Buckets de Storage existentes
SELECT id, name, public, created_at FROM storage.buckets ORDER BY created_at;
```

## 3. Resultados (pegar aquí tras ejecutar en el dashboard)

### 3.1 Schemas
_pendiente_

### 3.2 Tablas
_pendiente_

### 3.3 Columnas de public
_pendiente_

### 3.4 Políticas RLS
_pendiente_

### 3.5 Funciones
_pendiente_

### 3.6 Triggers
_pendiente_

### 3.7 Buckets
_pendiente_

## 4. Verificación post-migración (que The W no fue tocado)

Tras ejecutar las migraciones de `migrations/`, vuelve a correr 2.2, 2.4 y 2.7:
- Las tablas de `public` deben ser **idénticas** a la captura previa.
- Las únicas políticas nuevas deben empezar por `selektor_` (y las de storage,
  limitadas a `bucket_id LIKE 'selektor-%'`).
- Los únicos buckets nuevos: `selektor-candidate-documents` y `selektor-company-assets`.
