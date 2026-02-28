-- =============================================================================
-- MIGRACIÓN 001 — Modelo Multi-Unidad (N:M) para Personal de Salud
-- =============================================================================
-- Fecha     : 2026-02-28
-- ADR       : docs/decisions/ADR-001-esquema-multi-unidad.md
-- Opción    : A — Modelo Híbrido (APROBADA)
-- Rama      : claude/sires-development-phase-DMBiM
--
-- Decisiones aprobadas:
--   P1. Un usuario SÍ puede tener más de un rol en la misma unidad
--       → Constraint: UNIQUE PARTIAL por (usuario_id, unidad_medica_id, rol_id) WHERE activo = TRUE
--   P2. Login muestra SELECTOR DE UNIDAD cuando el usuario tiene más de una asignación activa
--   P3. adm_usuarios.rol_id se conserva SOLO para SUPERADMIN (rol de sistema)
--       Roles operativos (ADMIN_UNIDAD, MEDICO, ENFERMERA, RECEPCIONISTA) → adm_usuario_unidad_rol
--   P4. Historial COMPLETO con fecha_inicio/fecha_fin — todo movimiento auditable (NOM-024)
--
-- Para ejecutar:
--   psql -U postgres -d ece_global -f docs/migrations/001_multi_unidad.sql
--
-- ⚠️  EJECUTAR SIEMPRE DESPUÉS DE UN BACKUP:
--   pg_dump -U postgres ece_global > docs/backups/pre-migration-multi-unidad_$(date +%Y%m%d_%H%M).sql
-- =============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- PASO 1 — Crear tabla puente adm_usuario_unidad_rol
-- ---------------------------------------------------------------------------
-- Cada fila representa UNA asignación de un usuario a una unidad con un rol.
-- Las filas activas (activo = TRUE) representan el estado actual.
-- Las filas inactivas (activo = FALSE, fecha_fin NOT NULL) son historial inmutable.

CREATE TABLE IF NOT EXISTS adm_usuario_unidad_rol (
    id               UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id       UUID        NOT NULL REFERENCES adm_usuarios(id) ON DELETE CASCADE,
    unidad_medica_id INTEGER     NOT NULL REFERENCES adm_unidades_medicas(id) ON DELETE RESTRICT,
    rol_id           INTEGER     NOT NULL REFERENCES cat_roles(id),

    -- Estado de la asignación
    activo           BOOLEAN     NOT NULL DEFAULT TRUE,
    fecha_inicio     DATE        NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin        DATE,          -- NULL = vigente indefinidamente

    -- Trazabilidad NOM-024
    motivo_cambio    TEXT,          -- Descripción del motivo de alta/baja/cambio
    created_by       UUID        REFERENCES adm_usuarios(id),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE adm_usuario_unidad_rol IS
    'Tabla puente N:M entre usuarios y unidades médicas con rol por asignación. '
    'Las filas inactivas (activo=FALSE) conservan el historial completo de asignaciones.';

COMMENT ON COLUMN adm_usuario_unidad_rol.activo IS
    'TRUE = asignación vigente. FALSE = asignación cerrada (historial).';
COMMENT ON COLUMN adm_usuario_unidad_rol.fecha_fin IS
    'Fecha en que se cerró la asignación. NULL si sigue vigente.';
COMMENT ON COLUMN adm_usuario_unidad_rol.motivo_cambio IS
    'Motivo de alta, baja o cambio de rol — requerido para trazabilidad NOM-024.';

-- Solo puede existir UNA asignación ACTIVA por (usuario, unidad, rol)
-- Las filas con activo=FALSE (historial) no entran en este índice único
CREATE UNIQUE INDEX uq_uur_activa
    ON adm_usuario_unidad_rol(usuario_id, unidad_medica_id, rol_id)
    WHERE activo = TRUE;

-- Índices de búsqueda frecuente
CREATE INDEX idx_uur_usuario  ON adm_usuario_unidad_rol(usuario_id)       WHERE activo = TRUE;
CREATE INDEX idx_uur_unidad   ON adm_usuario_unidad_rol(unidad_medica_id) WHERE activo = TRUE;
CREATE INDEX idx_uur_historial ON adm_usuario_unidad_rol(usuario_id, fecha_inicio DESC);


-- ---------------------------------------------------------------------------
-- PASO 2 — Migrar datos existentes de adm_personal_salud a la tabla puente
-- ---------------------------------------------------------------------------
-- Convierte el campo unidad_medica_id de cada registro de personal en el
-- primer registro histórico de adm_usuario_unidad_rol.
-- Solo se migran registros de roles OPERATIVOS (no SUPERADMIN).

INSERT INTO adm_usuario_unidad_rol
    (usuario_id, unidad_medica_id, rol_id, activo, fecha_inicio, motivo_cambio)
SELECT
    p.usuario_id,
    p.unidad_medica_id,
    u.rol_id,
    TRUE,
    CURRENT_DATE,
    'Migración inicial: modelo multi-unidad ADR-001'
FROM adm_personal_salud p
JOIN adm_usuarios u        ON p.usuario_id = u.id
JOIN cat_roles r           ON u.rol_id = r.id
WHERE p.unidad_medica_id IS NOT NULL
  AND r.clave NOT IN ('SUPERADMIN')
  AND u.activo = TRUE;


-- ---------------------------------------------------------------------------
-- PASO 3 — Eliminar columna unidad_medica_id de adm_personal_salud
-- ---------------------------------------------------------------------------
-- adm_personal_salud se convierte en perfil profesional puro (datos biográficos
-- y credenciales). La asignación de unidades vive en adm_usuario_unidad_rol.

ALTER TABLE adm_personal_salud DROP COLUMN IF EXISTS unidad_medica_id;

-- Garantizar que un usuario solo tenga UN perfil profesional
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'uq_personal_usuario'
          AND conrelid = 'adm_personal_salud'::regclass
    ) THEN
        ALTER TABLE adm_personal_salud
            ADD CONSTRAINT uq_personal_usuario UNIQUE (usuario_id);
    END IF;
END $$;


-- ---------------------------------------------------------------------------
-- PASO 4 — Trigger para mantener updated_at automático
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_uur_updated_at ON adm_usuario_unidad_rol;
CREATE TRIGGER trg_uur_updated_at
    BEFORE UPDATE ON adm_usuario_unidad_rol
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- ---------------------------------------------------------------------------
-- PASO 5 — Verificación de integridad post-migración
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    v_personal_sin_asig INTEGER;
    v_asignaciones      INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_asignaciones FROM adm_usuario_unidad_rol WHERE activo = TRUE;
    SELECT COUNT(*) INTO v_personal_sin_asig
        FROM adm_personal_salud p
        LEFT JOIN adm_usuario_unidad_rol a ON a.usuario_id = p.usuario_id AND a.activo = TRUE
        WHERE a.id IS NULL;

    RAISE NOTICE '✅ Migración completada.';
    RAISE NOTICE '   adm_usuario_unidad_rol filas activas : %', v_asignaciones;
    RAISE NOTICE '   Personal sin asignaciones activas   : % (normal para recién creados)', v_personal_sin_asig;
END $$;

COMMIT;

-- =============================================================================
-- FIN DE MIGRACIÓN 001
-- =============================================================================
