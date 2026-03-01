-- ============================================================
-- MIGRACIÓN 002 — Campos de nombre desglosados + PDF local GIIS
-- Ejecutar con:
--   psql -U postgres -d ece_global -f docs/migrations/002_campos_nombre_giis_pdf.sql
-- ============================================================

BEGIN;

-- 1. Campos de nombre desglosados en adm_personal_salud
--    (nombre_completo se mantiene para compatibilidad y búsquedas)
ALTER TABLE adm_personal_salud
  ADD COLUMN IF NOT EXISTS primer_nombre    VARCHAR(100),
  ADD COLUMN IF NOT EXISTS segundo_nombre   VARCHAR(100),
  ADD COLUMN IF NOT EXISTS apellido_paterno VARCHAR(100),
  ADD COLUMN IF NOT EXISTS apellido_materno VARCHAR(100);

-- 2. Columna para ruta de PDF local en normativas GIIS
ALTER TABLE sys_normatividad_giis
  ADD COLUMN IF NOT EXISTS ruta_pdf_local VARCHAR(500);

-- 3. Deshabilitar TODAS las unidades médicas para iniciar pruebas en limpio
--    (quedan en catálogo activo=false, se habilitan individualmente desde la UI)
UPDATE adm_unidades_medicas
SET activo = false,
    updated_at = NOW()
WHERE activo = true;

-- Confirmar cambios
DO $$
DECLARE
  v_unidades_deshabilitadas INT;
BEGIN
  SELECT COUNT(*) INTO v_unidades_deshabilitadas
  FROM adm_unidades_medicas
  WHERE activo = false;

  RAISE NOTICE 'Migración 002 completada:';
  RAISE NOTICE '  - Columnas primer_nombre, segundo_nombre, apellido_paterno, apellido_materno añadidas a adm_personal_salud';
  RAISE NOTICE '  - Columna ruta_pdf_local añadida a sys_normatividad_giis';
  RAISE NOTICE '  - % unidades médicas deshabilitadas (activo=false)', v_unidades_deshabilitadas;
END $$;

COMMIT;
