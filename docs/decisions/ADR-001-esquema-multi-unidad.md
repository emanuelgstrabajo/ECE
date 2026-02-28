# ADR-001 — Esquema Multi-Unidad para Personal de Salud

**Fecha:** 2026-02-28
**Estado:** ✅ APROBADO — Implementando en `claude/sires-development-phase-DMBiM`
**Autor:** Claude (SIRES Dev Agent)
**Contexto:** Fase 1B completada — previo a Fase 2 (ADMIN_UNIDAD)

---

## 1. Problema

El esquema actual implementa una relación **1-a-1** entre un profesional de salud
y una unidad médica:

```sql
-- ESTADO ANTERIOR (ya migrado)
CREATE TABLE adm_personal_salud (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id       UUID NOT NULL REFERENCES adm_usuarios(id),
    unidad_medica_id INTEGER REFERENCES adm_unidades_medicas(id), -- ← ELIMINADA
    tipo_personal_id INTEGER NOT NULL REFERENCES cat_tipos_personal(id),
    cedula_profesional VARCHAR(20),
    nombre_completo  VARCHAR(255) NOT NULL
);
```

**Consecuencias operativas del modelo 1-a-1:**

| # | Escenario real | Problema |
|---|---------------|----------|
| 1 | Médico trabaja en IMSS Culiacán + IMSS Navolato | Imposible — solo existe un `unidad_medica_id` |
| 2 | Enfermera es ADMIN_UNIDAD en su clínica | No hay rol por unidad, el rol es global en `adm_usuarios.rol_id` |
| 3 | SUPERADMIN asigna médico a nueva unidad sin borrar la anterior | Pierde historial o requiere borrar el registro |
| 4 | Fase 2: middleware de scope de unidad | El token emite un solo `unidad_medica_id` → scope correcto pero inflexible |
| 5 | Un médico de guardia cubre varias clínicas | Requiere duplicar registros en `adm_personal_salud` |

---

## 2. Decisión: OPCIÓN A — Modelo Híbrido

### Tabla puente `adm_usuario_unidad_rol`

Introduce una tabla N:M que registra cada asignación **usuario ↔ unidad ↔ rol**.
`adm_personal_salud` queda como perfil profesional puro (nombre, cédula, tipo),
sin `unidad_medica_id`.

```sql
-- Ver migración completa en: docs/migrations/001_multi_unidad.sql

CREATE TABLE adm_usuario_unidad_rol (
    id               UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id       UUID        NOT NULL REFERENCES adm_usuarios(id) ON DELETE CASCADE,
    unidad_medica_id INTEGER     NOT NULL REFERENCES adm_unidades_medicas(id) ON DELETE RESTRICT,
    rol_id           INTEGER     NOT NULL REFERENCES cat_roles(id),
    activo           BOOLEAN     NOT NULL DEFAULT TRUE,
    fecha_inicio     DATE        NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin        DATE,          -- NULL = vigente
    motivo_cambio    TEXT,          -- Trazabilidad NOM-024
    created_by       UUID        REFERENCES adm_usuarios(id),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Una asignación activa por (usuario, unidad, rol) — historial no restringido
CREATE UNIQUE INDEX uq_uur_activa
    ON adm_usuario_unidad_rol(usuario_id, unidad_medica_id, rol_id)
    WHERE activo = TRUE;
```

---

## 3. Preguntas Abiertas — Respondidas

| # | Pregunta | Respuesta |
|---|----------|-----------|
| P1 | ¿Un usuario puede tener más de un rol en la misma unidad? | **SÍ** → Constraint parcial por `(usuario_id, unidad_medica_id, rol_id) WHERE activo = TRUE` |
| P2 | ¿Login muestra selector si hay múltiples unidades? | **SÍ — muestra selector** de unidad/rol disponibles |
| P3 | ¿`adm_usuarios.rol_id` se conserva o migra? | **Se conserva solo para SUPERADMIN** (rol de sistema). Roles operativos se gestionan en `adm_usuario_unidad_rol` |
| P4 | ¿Historial completo o solo estado activo? | **Historial completo** — `fecha_inicio` + `fecha_fin` + `motivo_cambio`. Todo movimiento auditable (NOM-024) |

---

## 4. Arquitectura del Nuevo Flujo de Login

```
POST /api/auth/login
  │
  ├─ Validar credenciales (igual que antes)
  │
  ├─ ¿Es SUPERADMIN?
  │     └─ SÍ → Emitir access token (unidad_medica_id: null)
  │
  └─ No SUPERADMIN → cargar asignaciones activas de adm_usuario_unidad_rol
        │
        ├─ 0 asignaciones → 401 "Sin asignaciones activas"
        ├─ 1 asignación   → Emitir access token directamente
        └─ N asignaciones → Devolver lista para selector
                              { requires_unit_selection: true, unidades: [...] }
                              + pre_token (JWT corto, 5 min, type: 'unit_selection')

POST /api/auth/seleccionar-unidad
  Body: { asignacion_id: "uuid" }
  Valida pre_token → emite access token completo con contexto de unidad
```

### Payload del Access Token (operativo)

```json
{
  "sub": "uuid-usuario",
  "email": "medico@clinic.mx",
  "curp": "XXXX...",
  "rol": "MEDICO",
  "rol_id": 3,
  "unidad_medica_id": 5,
  "asignacion_id": "uuid-asignacion",
  "nombre": "Dr. García López",
  "personal_id": "uuid-personal"
}
```

### Payload del Access Token (SUPERADMIN)

```json
{
  "sub": "uuid-usuario",
  "email": "admin@ece.mx",
  "curp": "XXXX...",
  "rol": "SUPERADMIN",
  "rol_id": 1,
  "unidad_medica_id": null,
  "asignacion_id": null,
  "nombre": "Administrador Sistema"
}
```

---

## 5. Gestión del Rol en `adm_usuarios.rol_id`

| Caso | `adm_usuarios.rol_id` | Rol en token |
|------|-----------------------|--------------|
| SUPERADMIN | `rol_id` → SUPERADMIN | Siempre SUPERADMIN |
| Roles operativos | NULL o rol base (referencial) | Viene de `adm_usuario_unidad_rol.rol_id` de la asignación seleccionada |

**Regla:** Al crear un usuario operativo, `adm_usuarios.rol_id` puede ser NULL.
El rol real se determina por sus asignaciones activas.

---

## 6. Nuevos Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/api/auth/seleccionar-unidad` | Emite token con unidad/rol seleccionado |
| `GET`  | `/api/admin/usuarios/:id/asignaciones` | Lista asignaciones (activas + historial) |
| `POST` | `/api/admin/usuarios/:id/asignaciones` | Crea nueva asignación |
| `DELETE` | `/api/admin/usuarios/:id/asignaciones/:asig_id` | Revoca asignación (cierre lógico con fecha_fin) |

---

## 7. Archivos Modificados

| Archivo | Tipo de cambio |
|---------|---------------|
| `docs/migrations/001_multi_unidad.sql` | DDL + DML de migración (**nuevo**) |
| `backend/src/controllers/authController.js` | Login multi-unidad + `seleccionarUnidad` + refresh |
| `backend/src/controllers/personalController.js` | Quitar `unidad_medica_id` + nuevo CRUD asignaciones |
| `backend/src/controllers/usuariosController.js` | JOINs con tabla puente |
| `backend/src/routes/admin.js` | Rutas de asignaciones |
| `backend/src/routes/auth.js` | Ruta `seleccionar-unidad` |

---

## 8. Justificación Final

1. **Correctitud clínica:** `adm_personal_salud` es el perfil inmutable del profesional.
   Las atenciones históricas apuntan al mismo `personal_id` sin importar reasignaciones.

2. **NOM-024-SSA3-2010:** La norma exige trazabilidad del profesional que firmó el registro.
   El campo `fecha_fin` + `motivo_cambio` en `adm_usuario_unidad_rol` cubre este requisito.

3. **Costo de migración acotado:** Ver `docs/migrations/001_multi_unidad.sql`.
   Los datos existentes se migran sin pérdida de información.

4. **Preparación para Fase 2:** `ADMIN_UNIDAD` tendrá scope sobre su `unidad_medica_id` del token.
   El middleware de Fase 2 no cambia su contrato — solo valida `unidad_medica_id`.

---

*Documento aprobado. Implementación en progreso.*
