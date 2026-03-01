-- =============================================================================
-- MIGRACIÓN 004 — Roles faltantes en cat_roles
-- =============================================================================
-- Fecha     : 2026-03-01
-- Problema  : La BD solo tenía SUPERADMIN (1) y MEDICO (2).
--             Faltan ADMIN_UNIDAD, ENFERMERA, RECEPCIONISTA, PACIENTE.
--
-- ⚠️  PRERREQUISITO: ejecutar ANTES las migraciones 002 y 003:
--   psql -U postgres -d ece_global -f docs/migrations/002_campos_nombre_giis_pdf.sql
--   psql -U postgres -d ece_global -f docs/migrations/003_nombres_desglosados_nom024.sql
--
-- Para ejecutar esta migración:
--   psql -U postgres -d ece_global -f docs/migrations/004_roles_faltantes.sql
-- =============================================================================

BEGIN;

INSERT INTO cat_roles (clave, nombre, descripcion, activo) VALUES
  ('ADMIN_UNIDAD',  'Administrador de Unidad', 'Administra su unidad: personal, roles, catálogos adoptados', TRUE),
  ('ENFERMERA',     'Enfermera / Enfermero',   'Signos vitales, notas de enfermería',                        TRUE),
  ('RECEPCIONISTA', 'Recepcionista',            'Abre expedientes, agenda citas, lista de espera',            TRUE),
  ('PACIENTE',      'Paciente',                 'Solo lectura: su expediente, citas y documentos',            TRUE)
ON CONFLICT (clave) DO NOTHING;

DO $$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count FROM cat_roles;
  RAISE NOTICE '=== Migración 004 completada ===';
  RAISE NOTICE 'cat_roles ahora tiene % roles', v_count;
END $$;

COMMIT;
