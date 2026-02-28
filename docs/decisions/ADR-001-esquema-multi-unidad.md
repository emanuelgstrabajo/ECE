# ADR-001 — Esquema Multi-Unidad para Personal de Salud

**Fecha:** 2026-02-28
**Estado:** EN REVISIÓN — Pendiente de aprobación antes de ejecutar cualquier DDL
**Autor:** Claude (SIRES Dev Agent)
**Contexto:** Fase 1B completada — previo a Fase 2 (ADMIN_UNIDAD)

---

## 1. Problema

El esquema actual implementa una relación **1-a-1** entre un profesional de salud
y una unidad médica:

```sql
-- ESTADO ACTUAL
CREATE TABLE adm_personal_salud (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id       UUID NOT NULL REFERENCES adm_usuarios(id),   -- 1 usuario = 1 perfil
    unidad_medica_id INTEGER REFERENCES adm_unidades_medicas(id), -- 1 unidad, NULLABLE
    tipo_personal_id INTEGER NOT NULL REFERENCES cat_tipos_personal(id),
    cedula_profesional VARCHAR(20),
    nombre_completo  VARCHAR(255) NOT NULL
);

-- adm_usuarios también tiene rol global
-- ALTER TABLE adm_usuarios ADD COLUMN rol_id INTEGER REFERENCES cat_roles(id);
```

**Consecuencias operativas del modelo 1-a-1:**

| # | Escenario real | Problema |
|---|---------------|----------|
| 1 | Médico trabaja en IMSS Culiacán + IMSS Navolato | Imposible — solo existe un `unidad_medica_id` |
| 2 | Enfermera es ADMIN_UNIDAD en su clínica | No hay rol por unidad, el rol es global en `adm_usuarios.rol_id` |
| 3 | SUPERADMIN asigna médico a nueva unidad sin borrar la anterior | Pierde historial o requiere borrar el registro |
| 4 | Fase 2: middleware de scope de unidad | El token emite un solo `unidad_medica_id` → scope correcto pero inflexible |
| 5 | Un médico de guardia cubre varias clínicas | Requiere duplicar registros en `adm_personal_salud` |

**Código afectado actualmente:**

```
authController.js:129-136   → LIMIT 1 al buscar personal (asume 1 unidad)
authController.js:157       → tokenPayload.unidad_medica_id (scalar, no array)
authController.js:232       → refresh también usa LIMIT 1
usuariosController.js:25    → LEFT JOIN adm_personal_salud p ON p.usuario_id = u.id (asume 1-a-1)
personalController.js:80    → Valida unicidad de usuario_id en personal_salud
personalController.js:27    → Query de listado une por unidad_medica_id scalar
```

---

## 2. Objetivo

Soportar un modelo **muchos-a-muchos** (N:M) entre usuarios y unidades médicas,
donde cada asignación puede tener un **rol diferente** (MEDICO en una unidad,
ADMIN_UNIDAD en otra, p. ej.), sin romper la trazabilidad clínica existente.

---

## 3. Opciones Consideradas

---

### OPCIÓN A — Modelo Híbrido (RECOMENDADA)

Introduce una **tabla puente** `adm_usuario_unidad_rol` que registra cada asignación
usuario ↔ unidad ↔ rol. `adm_personal_salud` se convierte en perfil profesional puro
(datos biográficos/credenciales), sin `unidad_medica_id`.

```sql
-- adm_personal_salud: solo perfil profesional (sin unidad)
ALTER TABLE adm_personal_salud DROP COLUMN unidad_medica_id;
ALTER TABLE adm_personal_salud ADD CONSTRAINT uq_personal_usuario UNIQUE (usuario_id);

-- Nueva tabla puente
CREATE TABLE adm_usuario_unidad_rol (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id       UUID    NOT NULL REFERENCES adm_usuarios(id) ON DELETE CASCADE,
    unidad_medica_id INTEGER NOT NULL REFERENCES adm_unidades_medicas(id) ON DELETE RESTRICT,
    rol_id           INTEGER NOT NULL REFERENCES cat_roles(id),
    activo           BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_inicio     DATE    NOT NULL DEFAULT CURRENT_DATE,
    fecha_fin        DATE,   -- NULL = sin expiración
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_usuario_unidad UNIQUE (usuario_id, unidad_medica_id)
    -- Un usuario tiene UN rol por unidad; si se necesita más de un rol
    -- por unidad en el futuro, se elimina esta constraint.
);

CREATE INDEX idx_uur_usuario   ON adm_usuario_unidad_rol(usuario_id)  WHERE activo = TRUE;
CREATE INDEX idx_uur_unidad    ON adm_usuario_unidad_rol(unidad_medica_id) WHERE activo = TRUE;
```

**Cambio en JWT (sesión activa):**
El usuario selecciona su unidad al hacer login (si tiene varias). El token incluye:
```json
{
  "sub": "uuid",
  "rol": "MEDICO",
  "unidad_medica_id": 5,
  "unidades_disponibles": [5, 12]
}
```
Para SUPERADMIN/ADMIN_UNIDAD sin asignación específica, `unidad_medica_id` puede ser `null`.

**Flujo de asignación:**
```
SUPERADMIN crea usuario → adm_usuarios (rol_id = base o null para ops)
SUPERADMIN/ADMIN_UNIDAD asigna unidad → INSERT INTO adm_usuario_unidad_rol
Login → SELECT unidades del usuario → token con unidad_activa
```

**Impacto en `clin_citas` y `clin_atenciones`:**
Las FKs `personal_salud_id → adm_personal_salud(id)` se mantienen **sin cambio**.
El perfil profesional es estable; la asignación de unidades varía independientemente.

#### Pros de Opción A
- ✅ Modela correctamente la realidad clínica (multi-unidad, multi-rol)
- ✅ `adm_personal_salud` queda como perfil estable — `clin_citas`/`clin_atenciones` no cambian
- ✅ Historial de asignaciones con `fecha_inicio`/`fecha_fin` (auditable, NOM-024)
- ✅ Rol operativo es por-unidad; `adm_usuarios.rol_id` puede reservarse para SUPERADMIN
- ✅ El middleware de scope de Fase 2 solo necesita validar `unidad_medica_id` del token (mismo contrato que hoy)
- ✅ Migración de datos sencilla: el `unidad_medica_id` actual de cada registro de personal_salud se convierte en el primer registro en `adm_usuario_unidad_rol`
- ✅ Permite borrado lógico (`activo = FALSE`) sin perder historial de asignaciones

#### Contras de Opción A
- ⚠️ Requiere refactorizar `authController.js` (login + refresh) para manejar múltiples unidades
- ⚠️ Si el usuario tiene N unidades, el login debe presentar un selector de unidad activa (UX adicional)
- ⚠️ El token JWT cambia su estructura: `unidad_medica_id` pasa a ser la unidad seleccionada, se agrega `unidades_disponibles`
- ⚠️ `personalController.js` debe ser refactorizado (ya no gestiona asignaciones de unidad directamente)
- ⚠️ DDL requiere ejecutarse con cuidado: `DROP COLUMN` con datos existentes requiere migración previa

**Complejidad estimada:** Media — 3 archivos de controller + 2 de middleware + SQL migration

---

### OPCIÓN B — Tabla de Asignaciones Adicionales (Conservadora)

Mantiene `adm_personal_salud.unidad_medica_id` como "unidad primaria" y agrega una
tabla para unidades secundarias.

```sql
CREATE TABLE adm_personal_unidades_extra (
    personal_id      UUID    NOT NULL REFERENCES adm_personal_salud(id) ON DELETE CASCADE,
    unidad_medica_id INTEGER NOT NULL REFERENCES adm_unidades_medicas(id),
    rol_id           INTEGER REFERENCES cat_roles(id),
    activo           BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (personal_id, unidad_medica_id)
);
```

#### Pros de Opción B
- ✅ Cero cambios en código existente (todo funciona con la unidad primaria)
- ✅ Despliegue en minutos — solo un `CREATE TABLE`
- ✅ No rompe FKs ni JWT

#### Contras de Opción B
- ❌ Asimetría conceptual: "unidad primaria" vs "unidades adicionales" — ¿cuál es la activa?
- ❌ Duplica lógica de scope en Fase 2 (hay que buscar en dos tablas)
- ❌ El rol operativo sigue siendo global en `adm_usuarios.rol_id` — no resuelve el rol por-unidad
- ❌ Acumula deuda técnica que habrá que pagar igual en Fase 2
- ❌ Si se mueve la unidad "primaria" a la tabla nueva, el campo en `adm_personal_salud` queda obsoleto

**Complejidad estimada:** Baja ahora, Alta después al llegar a Fase 2

---

### OPCIÓN C — Reestructuración Radical

Elimina `adm_personal_salud` completamente. Consolida todo en `adm_usuario_unidad_rol`
con columnas adicionales (nombre, cédula, tipo). Las FKs clínicas cambian a `usuario_id`.

```sql
-- Hipotética nueva estructura
CREATE TABLE adm_usuario_unidad_rol (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id       UUID    NOT NULL REFERENCES adm_usuarios(id),
    unidad_medica_id INTEGER NOT NULL REFERENCES adm_unidades_medicas(id),
    rol_id           INTEGER NOT NULL REFERENCES cat_roles(id),
    nombre_completo  VARCHAR(255),  -- desnormalizado
    cedula_profesional VARCHAR(20),
    tipo_personal_id INTEGER REFERENCES cat_tipos_personal(id),
    ...
);
-- clin_citas.personal_salud_id → ??? (cambiaría a usuario_id o asignacion_id)
```

#### Pros de Opción C
- ✅ Schema conceptualmente más simple (una tabla menos)
- ✅ No existe dicotomía usuario/personal

#### Contras de Opción C
- ❌ Rompe FKs en `clin_citas` y `clin_atenciones` (tabla particionada — migración muy compleja)
- ❌ Desnormaliza datos profesionales (nombre, cédula se repiten por unidad)
- ❌ Si el profesional se desasigna de la unidad, ¿qué queda en el registro clínico histórico?
- ❌ Alto riesgo para la integridad del expediente — conflicto directo con NOM-024
- ❌ Requiere reescribir prácticamente todos los controllers

**Complejidad estimada:** Muy Alta — no recomendada

---

## 4. Decisión Recomendada: OPCIÓN A

### Justificación

1. **Correctitud clínica**: El perfil profesional (`adm_personal_salud`) es estable e independiente
   de dónde trabaja el profesional. Las atenciones históricas siempre apuntarán a la misma identidad.

2. **Compatibilidad con NOM-024-SSA3-2010**: La norma exige trazabilidad del profesional que
   firmó el registro. Un `personal_salud_id` inmutable satisface esto mejor que un vínculo
   a una asignación que puede terminar.

3. **Costo de migración acotado**: El DDL de migración es predecible. Los datos actuales
   en `adm_personal_salud.unidad_medica_id` se migran 1-a-1 como primer registro en
   `adm_usuario_unidad_rol`. No hay pérdida de información.

4. **Contratos de API preservados**: La Fase 2 ya planea validar `unidad_medica_id` del
   token en un middleware. La Opción A mantiene ese contrato; solo agrega la selección de
   unidad activa al login.

5. **Preparación para Fase 2**: `ADMIN_UNIDAD` tiene scope sobre su `unidad_medica_id`.
   Con la tabla puente, el SUPERADMIN puede asignar y revocar accesos por unidad sin
   tocar `adm_usuarios.rol_id`.

---

## 5. Plan de Migración (si se aprueba Opción A)

> ⚠️ **Ningún DDL se ejecutará sin aprobación explícita de este documento.**

```
PASO 1 — Backup previo
  pg_dump -U postgres ece_global > docs/backups/pre-migration-multi-unidad.sql

PASO 2 — DDL: crear tabla puente
  CREATE TABLE adm_usuario_unidad_rol (...)

PASO 3 — Migrar datos existentes
  INSERT INTO adm_usuario_unidad_rol (usuario_id, unidad_medica_id, rol_id, fecha_inicio)
  SELECT p.usuario_id, p.unidad_medica_id, u.rol_id, CURRENT_DATE
  FROM adm_personal_salud p
  JOIN adm_usuarios u ON p.usuario_id = u.id
  WHERE p.unidad_medica_id IS NOT NULL;

PASO 4 — Validar integridad (contar registros migrados)

PASO 5 — DDL: eliminar columna de personal_salud
  ALTER TABLE adm_personal_salud DROP COLUMN unidad_medica_id;
  ALTER TABLE adm_personal_salud ADD CONSTRAINT uq_personal_usuario UNIQUE (usuario_id);

PASO 6 — Refactorizar código
  authController.js     → login + refresh
  personalController.js → CRUD de asignaciones
  usuariosController.js → JOIN con nueva tabla
  middleware/verifyToken.js → sin cambio (valida token existente)

PASO 7 — Nuevos endpoints
  POST   /api/admin/usuarios/:id/asignaciones
  GET    /api/admin/usuarios/:id/asignaciones
  DELETE /api/admin/usuarios/:id/asignaciones/:unidad_id
  POST   /api/auth/seleccionar-unidad  ← (si usuario tiene >1 unidad)

PASO 8 — Tests y checkpoint
  git tag pre-migration-multi-unidad
```

**Archivos a modificar:**

| Archivo | Tipo de cambio |
|---------|---------------|
| `backend/src/controllers/authController.js` | Refactor login + refresh |
| `backend/src/controllers/personalController.js` | Nuevo CRUD asignaciones |
| `backend/src/controllers/usuariosController.js` | JOINs con tabla puente |
| `backend/src/routes/admin.js` | Nuevas rutas de asignaciones |
| SQL de migración (nuevo archivo) | DDL + DML de migración |

---

## 6. Preguntas Abiertas para el Equipo

Antes de ejecutar la migración, confirmar:

1. **¿Un usuario puede tener más de un rol en la misma unidad?**
   - Si NO → `UNIQUE (usuario_id, unidad_medica_id)` ✅
   - Si SÍ → Quitar esa constraint y agregar `rol_id` a la PK compuesta

2. **¿El login muestra selector de unidad si hay múltiples, o siempre entra a la "última activa"?**
   - Afecta diseño de `POST /api/auth/seleccionar-unidad`

3. **¿`adm_usuarios.rol_id` se conserva para SUPERADMIN y se ignora para roles operativos,
   o se migra también a la tabla puente?**
   - SUPERADMIN no tiene unidad → se queda en `adm_usuarios.rol_id`
   - Roles operativos → se gestionan en `adm_usuario_unidad_rol`
   - ¿O se crea un registro en `adm_usuario_unidad_rol` con `unidad_medica_id = NULL` para SUPERADMIN?

4. **¿Se necesita historial de asignaciones pasadas (fecha_fin) o solo el estado activo?**
   - Si solo activo → `BOOLEAN activo` es suficiente
   - Si historial → `fecha_inicio`/`fecha_fin` es importante para auditoría NOM-024

---

*Documento generado por el agente de desarrollo SIRES. Ningún cambio a producción
hasta que este ADR sea aprobado y las preguntas abiertas respondidas.*
