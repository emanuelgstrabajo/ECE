-- ================================================================
-- MIGRACIÓN 003 — Nombres desglosados NOM-024-SSA3-2010
--
-- Estandariza el registro de nombres en tres tablas:
--   adm_personal_salud → primer_nombre, segundo_nombre,
--                         apellido_paterno, apellido_materno
--   clin_pacientes     → misma nomenclatura (renombrar columnas
--                         nombre→primer_nombre,
--                         primer_apellido→apellido_paterno,
--                         segundo_apellido→apellido_materno)
--
-- En ambas tablas se agrega nombre_completo como columna GENERADA
-- automáticamente (GENERATED ALWAYS AS STORED) para búsquedas y
-- compatibilidad con bitácora y PDFs.
--
-- Ejecutar con:
--   psql -U postgres -d ece_global -f docs/migrations/003_nombres_desglosados_nom024.sql
-- ================================================================

BEGIN;

-- ----------------------------------------------------------------
-- 1. adm_personal_salud
-- ----------------------------------------------------------------

-- tipo_personal_id: hacerlo nullable
-- (no todos los usuarios del sistema son personal clínico;
--  los administradores de unidad pueden carecer de tipo clínico)
ALTER TABLE adm_personal_salud
  ALTER COLUMN tipo_personal_id DROP NOT NULL;

-- primer_nombre y apellido_paterno: obligatorios (NOM-024)
ALTER TABLE adm_personal_salud
  ALTER COLUMN primer_nombre    SET NOT NULL,
  ALTER COLUMN apellido_paterno SET NOT NULL;

-- Reemplazar nombre_completo por columna GENERADA automáticamente
-- Orden: "Carlos Miguel García López" (nombre(s) + apellidos)
ALTER TABLE adm_personal_salud DROP COLUMN nombre_completo;
ALTER TABLE adm_personal_salud
  ADD COLUMN nombre_completo TEXT GENERATED ALWAYS AS (
    TRIM(
        primer_nombre
      || COALESCE(' ' || NULLIF(TRIM(segundo_nombre),   ''), '')
      || ' ' || apellido_paterno
      || COALESCE(' ' || NULLIF(TRIM(apellido_materno), ''), '')
    )
  ) STORED;

-- ----------------------------------------------------------------
-- 2. clin_pacientes
-- ----------------------------------------------------------------

-- Renombrar columnas a la nomenclatura NOM-024 estandarizada
ALTER TABLE clin_pacientes RENAME COLUMN nombre           TO primer_nombre;
ALTER TABLE clin_pacientes RENAME COLUMN primer_apellido  TO apellido_paterno;
ALTER TABLE clin_pacientes RENAME COLUMN segundo_apellido TO apellido_materno;

-- Agregar segundo_nombre (opcional según NOM-024)
ALTER TABLE clin_pacientes
  ADD COLUMN segundo_nombre VARCHAR(100);

-- Agregar nombre_completo generado
ALTER TABLE clin_pacientes
  ADD COLUMN nombre_completo TEXT GENERATED ALWAYS AS (
    TRIM(
        primer_nombre
      || COALESCE(' ' || NULLIF(TRIM(segundo_nombre),   ''), '')
      || ' ' || apellido_paterno
      || COALESCE(' ' || NULLIF(TRIM(apellido_materno), ''), '')
    )
  ) STORED;

-- Actualizar índices
DROP INDEX IF EXISTS idx_paciente_nombre;
DROP INDEX IF EXISTS idx_paciente_apellidos;
CREATE INDEX idx_paciente_primer_nombre   ON clin_pacientes (primer_nombre);
CREATE INDEX idx_paciente_apellidos       ON clin_pacientes (apellido_paterno, apellido_materno);
CREATE INDEX idx_paciente_nombre_completo ON clin_pacientes (nombre_completo);

-- ----------------------------------------------------------------
-- Confirmación
-- ----------------------------------------------------------------
DO $$
BEGIN
  RAISE NOTICE '=== Migración 003 completada ===';
  RAISE NOTICE 'adm_personal_salud:';
  RAISE NOTICE '  - tipo_personal_id ahora nullable';
  RAISE NOTICE '  - primer_nombre y apellido_paterno NOT NULL';
  RAISE NOTICE '  - nombre_completo = GENERATED ALWAYS AS STORED';
  RAISE NOTICE 'clin_pacientes:';
  RAISE NOTICE '  - nombre → primer_nombre';
  RAISE NOTICE '  - primer_apellido → apellido_paterno';
  RAISE NOTICE '  - segundo_apellido → apellido_materno';
  RAISE NOTICE '  - segundo_nombre agregado (nullable)';
  RAISE NOTICE '  - nombre_completo = GENERATED ALWAYS AS STORED';
  RAISE NOTICE '  - Índices actualizados';
END $$;

COMMIT;
