# ADR-002 — Alcance del Rol ADMIN_UNIDAD (Fase 2)

**Fecha:** 2026-02-28
**Estado:** ✅ APROBADO
**Autor:** Claude (SIRES Dev Agent)
**Contexto:** ADR-001 aprobado — decisiones de Fase 2 registradas

---

## Objetivo de este documento

Define qué puede y qué no puede hacer un `ADMIN_UNIDAD` dentro del sistema SIRES.
Estas decisiones determinan las rutas y controladores del backend, el middleware de
scope, la estructura del dashboard y las pantallas de gestión del frontend.

---

## Decisiones Aprobadas

### P1 — Gestión de personal y usuarios ✅
**Respuesta: D**

El ADMIN_UNIDAD puede:
- Crear cuentas completas (`adm_usuarios` + `adm_personal_salud`) con contraseña temporal
- Asignar roles operativos (MEDICO, ENFERMERA, RECEPCIONISTA) a usuarios de su unidad
- **Designar a otro usuario de su unidad como ADMIN_UNIDAD** (sin requerir al SUPERADMIN)

**Restricciones de implementación:**
- Un ADMIN_UNIDAD solo puede asignar roles ≤ su propio nivel (no puede crear SUPERADMIN)
- La designación de otro ADMIN_UNIDAD queda registrada en `sys_bitacora_auditoria`
- El SUPERADMIN siempre puede revisar y revocar cualquier asignación

---

### P2 — Reseteo de contraseñas ✅
**Respuesta: C**

El ADMIN_UNIDAD puede resetear contraseñas de:
- MEDICO, ENFERMERA, RECEPCIONISTA de su unidad

El ADMIN_UNIDAD **NO puede** resetear contraseñas de:
- Otros ADMIN_UNIDAD (aunque sean de su misma unidad)
- SUPERADMIN

El reset genera una contraseña temporal que el usuario debe cambiar en su primer login.

---

### P3 — Revocación de asignaciones ✅
**Respuesta: C**

El ADMIN_UNIDAD puede revocar asignaciones operativas (MEDICO, ENFERMERA, RECEPCIONISTA)
de su unidad, registrando motivo y fecha de cierre.

**NO puede** revocar la asignación de otro ADMIN_UNIDAD (requiere SUPERADMIN).

---

### P4 — Configuración de guías/normativas GIIS ✅
**Respuesta clarificada por el usuario:**

> "Los admin de unidad pueden decir qué guías reportarán de información."

El ADMIN_UNIDAD puede seleccionar cuáles de las normativas/formularios GIIS del
catálogo global estarán activos para su unidad. **No puede crear ni eliminar**
normativas del catálogo global (eso es exclusivo del SUPERADMIN).

**Implementación:** tabla `sys_adopcion_catalogos` o `rel_normatividad_opciones` —
el admin marca cuáles normativas adopta su unidad.

---

### P5 — Servicios de atención ✅
**Respuesta clarificada por el usuario:**

> "Solo podrán decir qué de lo global usará en particular su unidad. Ej: mi unidad
> solo tiene médicos de once y medicina general aunque todo el catálogo tenga más
> especialidades."

El ADMIN_UNIDAD activa/desactiva servicios del catálogo global para su unidad.
**No puede crear nuevos tipos de servicio.**

**Implementación:** tabla puente `unidad_servicios_activos` (o columna en
`cat_matriz_personal_servicio`) que registra qué servicios del catálogo global
están habilitados por unidad.

---

### P6 — Visibilidad sobre pacientes ✅
**Respuesta: C**

El ADMIN_UNIDAD tiene **acceso de lectura completo** al expediente de cualquier
paciente atendido en su unidad, para fines de auditoría interna.

**Nota NOM-024:** Todo acceso al expediente queda registrado en `sys_bitacora_auditoria`
con el campo `accion = 'CONSULTA_EXPEDIENTE'` y el `usuario_id` del admin.

---

### P7 — Gestión de agenda ✅
**Respuesta: C**

El ADMIN_UNIDAD tiene **control total** sobre la agenda de su unidad:
- Crear, cancelar y reprogramar citas
- Reasignar citas a otro médico disponible
- Ver disponibilidad de todos los médicos de su unidad

---

### P8 — Acceso a bitácora ✅
**Respuesta: D**

Vista completa de la bitácora, pero **solo de eventos de su unidad**:
- Acciones de todos los usuarios (operativos + pacientes) vinculados a la unidad
- Filtros por usuario, tipo de acción, rango de fechas
- No puede ver eventos de otras unidades (salvo excepción SUPERADMIN — ver P12)

---

### P9 — Cambio de unidad activa sin logout ✅
**Respuesta: B**

Sí. Habrá un **selector de contexto en el menú** que llama a `POST /auth/cambiar-unidad`
y emite un nuevo access token con la unidad seleccionada, sin invalidar la sesión.

**Caso de uso:** Un usuario que es ADMIN_UNIDAD en la Clínica Norte y MEDICO en la
Clínica Sur puede cambiar de contexto sin volver a hacer login.

**Implementación:** Endpoint nuevo `/auth/cambiar-unidad` — similar a `seleccionar-unidad`
pero parte de una sesión activa en lugar de un pre_token.

---

### P10 — Roles operativos combinados ✅
**Respuesta: Sí, con UI diferenciada**

Una persona puede tener ADMIN_UNIDAD + un rol operativo en la misma o diferente unidad.
La UI mostrará **secciones separadas y claramente etiquetadas**:

- Sección "Administración" → visible siempre que tenga rol ADMIN_UNIDAD activo
- Sección operativa (ej: "Enfermería") → visible **solo si tiene ese rol activo en
  la unidad de contexto actual**

No se mezclan acciones administrativas con operativas en la misma pantalla.

---

### P11 — Métricas del dashboard ✅
**Respuesta: Todas (A–I)**

El dashboard del ADMIN_UNIDAD mostrará:

| ID | Métrica |
|----|---------|
| A | Total de personal activo en la unidad |
| B | Citas del día: programadas / atendidas / canceladas |
| C | Citas de la semana (vista de semana actual) |
| D | Pacientes nuevos del mes |
| E | Ocupación por servicio (% citas completadas vs. capacidad) |
| F | Alertas: usuarios bloqueados que requieren desbloqueo |
| G | Normativas/formularios con actualización pendiente |
| H | Actividad reciente (últimas 10 acciones en bitácora de la unidad) |
| I | Comparativa mensual (atenciones este mes vs. mes anterior) |

---

### P12 — Aislamiento de datos entre unidades ✅
**Respuesta: B**

Aislamiento por defecto. El SUPERADMIN puede otorgar permisos de "vista cruzada"
en casos especiales (ej: red de clínicas, supervisión regional).

**Implementación:** campo `puede_ver_unidades` (UUID[] o tabla puente) en el perfil
del admin. Middleware valida si la unidad solicitada está en su lista de visibles.

---

## Resumen de decisiones

| # | Tema | Decisión |
|---|------|---------|
| P1 | Gestión de personal/usuarios | ✅ D — Puede crear cuentas y designar admins |
| P2 | Reseteo de contraseñas | ✅ C — Sí, excepto a otros ADMIN_UNIDAD |
| P3 | Revocar asignaciones | ✅ C — Sí, solo roles operativos |
| P4 | Guías GIIS | ✅ Selecciona cuáles del catálogo global usa su unidad |
| P5 | Servicios de atención | ✅ B — Activa/desactiva del catálogo global |
| P6 | Visibilidad pacientes | ✅ C — Lectura completa (con auditoría) |
| P7 | Gestión de agenda | ✅ C — Control total sobre agenda de su unidad |
| P8 | Bitácora | ✅ D — Vista completa solo de su unidad |
| P9 | Cambio de unidad sin logout | ✅ B — Selector en menú + nuevo token |
| P10 | Rol operativo combinado | ✅ Sí, UI diferenciada por sección |
| P11 | Métricas dashboard | ✅ Todas (A–I) |
| P12 | Aislamiento entre unidades | ✅ B — Por defecto total, SUPERADMIN puede delegar |

---

## Implicaciones técnicas para Fase 2

### Nuevos endpoints necesarios

```
# Gestión de usuarios (scope unidad)
POST   /api/admin-unidad/usuarios              → crear cuenta + asignación inicial
GET    /api/admin-unidad/usuarios              → lista de usuarios de la unidad
PATCH  /api/admin-unidad/usuarios/:id/password → resetear contraseña (no a admins)

# Asignaciones (scope unidad)
POST   /api/admin-unidad/asignaciones          → crear asignación operativa o admin
DELETE /api/admin-unidad/asignaciones/:id      → revocar (solo operativas)

# Catálogos de unidad
GET/PUT /api/admin-unidad/normativas           → normativas GIIS activas para su unidad
GET/PUT /api/admin-unidad/servicios            → servicios activos para su unidad

# Clínica (scope unidad)
GET    /api/admin-unidad/pacientes             → lista + expediente (lectura)
GET/POST/PATCH/DELETE /api/admin-unidad/citas  → control total agenda

# Bitácora
GET    /api/admin-unidad/bitacora              → filtrada por unidad_medica_id

# Sesión
POST   /api/auth/cambiar-unidad                → nuevo token sin logout

# Dashboard
GET    /api/admin-unidad/dashboard             → métricas A–I
```

### Cambios de BD necesarios (migración 002)

```sql
-- Activación de servicios por unidad (si no existe ya)
CREATE TABLE IF NOT EXISTS adm_unidad_servicios (
    unidad_medica_id INTEGER REFERENCES adm_unidades_medicas(id),
    servicio_id      INTEGER REFERENCES cat_servicios_atencion(id),
    activo           BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (unidad_medica_id, servicio_id)
);

-- Vista cruzada entre unidades (para P12=B)
ALTER TABLE adm_usuario_unidad_rol
    ADD COLUMN IF NOT EXISTS puede_ver_unidades INTEGER[] DEFAULT '{}';
```

---

## Próximos pasos

1. **ADR-003** — Cuestionario suplementario del SUPERADMIN (nuevas dudas surgidas de ADR-002)
2. **Migración 002** — Ejecutar DDL de cambios de BD de Fase 2
3. **Controladores ADMIN_UNIDAD** — backend completo
4. **Dashboard y páginas de gestión** — frontend Fase 2
