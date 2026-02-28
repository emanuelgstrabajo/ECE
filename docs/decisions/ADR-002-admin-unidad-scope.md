# ADR-002 — Alcance del Rol ADMIN_UNIDAD (Fase 2)

**Fecha:** 2026-02-28
**Estado:** ⏳ EN REVISIÓN — Pendiente de respuestas
**Autor:** Claude (SIRES Dev Agent)
**Contexto:** ADR-001 aprobado — iniciando diseño de Fase 2

---

## Objetivo de este documento

Definir con precisión qué puede y qué no puede hacer un `ADMIN_UNIDAD` dentro del
sistema SIRES. Las respuestas aquí determinarán:

- Las rutas y controladores a construir en el backend
- La estructura del dashboard del administrador
- El modelo de permisos dentro del middleware `requireUnidad`
- El alcance de los datos visibles en cada pantalla

Responde cada pregunta con el número/letra de la opción elegida o escribe
tu propia respuesta libre al final de cada sección.

---

## Sección 1 — Gestión de Personal y Usuarios en la Unidad

### P1. ¿Qué puede crear el ADMIN_UNIDAD sobre el personal?

Un administrador de unidad necesita gestionar a su equipo. ¿Cuánto poder tiene
sobre la creación de cuentas?

**Opciones:**

| # | Capacidad | Implicación técnica |
|---|-----------|---------------------|
| A | Solo puede ver el personal asignado a su unidad. No puede crear ni editar usuarios. | El SUPERADMIN gestiona todo lo relacionado a usuarios. El admin solo consulta. |
| B | Puede crear/editar perfiles de personal (`adm_personal_salud`) de su unidad, pero NO puede crear cuentas de acceso (`adm_usuarios`). Debe solicitar al SUPERADMIN. | Separación entre perfil profesional y credencial de acceso. |
| C | Puede crear cuentas completas (usuario + contraseña temporal) para personal de su unidad, con roles operativos (MEDICO, ENFERMERA, RECEPCIONISTA). NO puede crear otros ADMIN_UNIDAD. | Autonomía total del admin; mayor complejidad en el backend. |
| D | Puede hacer todo lo de C y además puede designar a otro usuario de su unidad como ADMIN_UNIDAD. | Delegación completa; riesgo de escalada de privilegios si no se valida. |

**Tu respuesta:** ___

---

### P2. ¿Puede el ADMIN_UNIDAD restablecer contraseñas?

Cuando un médico olvida su contraseña, ¿quién lo resuelve?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Solo el SUPERADMIN puede resetear contraseñas. |
| B | El ADMIN_UNIDAD puede resetear la contraseña de cualquier usuario asignado a su unidad (genera contraseña temporal). |
| C | El ADMIN_UNIDAD puede resetear, pero solo para usuarios con roles MEDICO / ENFERMERA / RECEPCIONISTA (no puede resetear a otro ADMIN_UNIDAD). |

**Tu respuesta:** ___

---

### P3. ¿Puede el ADMIN_UNIDAD revocar asignaciones?

Si un médico ya no trabaja en la unidad, ¿quién cierra su acceso?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Solo el SUPERADMIN puede revocar asignaciones. |
| B | El ADMIN_UNIDAD puede revocar cualquier asignación de su unidad (registrando motivo). |
| C | El ADMIN_UNIDAD puede revocar asignaciones operativas (MEDICO, ENFERMERA, RECEPCIONISTA) pero no puede revocar a otro ADMIN_UNIDAD de la misma unidad. |

**Tu respuesta:** ___

---

## Sección 2 — Catálogos y Normativas de la Unidad

### P4. ¿Puede el ADMIN_UNIDAD adoptar/rechazar normativas GIIS?

Cada unidad puede adoptar un subconjunto de las normativas GIIS (formularios
dinámicos). ¿Quién configura esto?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Solo el SUPERADMIN configura qué normativas adopta cada unidad. El admin no tiene acceso a esta pantalla. |
| B | El ADMIN_UNIDAD puede ver las normativas disponibles y marcar cuáles adopta su unidad (sin poder crear o eliminar normativas del catálogo global). |
| C | El ADMIN_UNIDAD puede gestionar normativas Y puede crear campos personalizados adicionales para su unidad (extiende el formulario base). |

**Tu respuesta:** ___

---

### P5. ¿Puede el ADMIN_UNIDAD gestionar los servicios de atención activos?

La tabla `cat_servicios_atencion` define los servicios que ofrece cada unidad
(consulta general, urgencias, laboratorio, etc.).

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Los servicios son globales y solo el SUPERADMIN los administra. |
| B | El ADMIN_UNIDAD puede activar/desactivar servicios para su unidad (marca cuáles ofrece), pero no puede crear nuevos tipos de servicio. |
| C | El ADMIN_UNIDAD puede crear servicios propios de su unidad además de activar/desactivar los globales. |

**Tu respuesta:** ___

---

## Sección 3 — Datos Clínicos (Pacientes y Citas)

### P6. ¿Qué visibilidad tiene el ADMIN_UNIDAD sobre pacientes?

Esta es una decisión crítica para la privacidad (NOM-024-SSA3).

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | El ADMIN_UNIDAD NO tiene acceso a expedientes clínicos individuales. Solo ve métricas agregadas (totales de citas, atenciones por servicio, etc.). |
| B | El ADMIN_UNIDAD puede ver la lista de pacientes atendidos en su unidad (nombre, CURP, última visita) pero NO puede abrir el expediente clínico. |
| C | El ADMIN_UNIDAD tiene acceso de lectura completo al expediente de cualquier paciente atendido en su unidad (para auditoría interna). |

**Tu respuesta:** ___

---

### P7. ¿Puede el ADMIN_UNIDAD gestionar la agenda de citas?

Quizás el administrador necesita resolver conflictos en la agenda.

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | La agenda es exclusiva del rol RECEPCIONISTA. El ADMIN_UNIDAD no puede modificar citas. |
| B | El ADMIN_UNIDAD puede ver la agenda de su unidad y cancelar/reprogramar citas (por ejemplo, si un médico no llegó). |
| C | El ADMIN_UNIDAD tiene control total sobre la agenda (crear, cancelar, reprogramar, asignar a otro médico). |

**Tu respuesta:** ___

---

## Sección 4 — Bitácora y Auditoría

### P8. ¿Qué parte de la bitácora puede ver el ADMIN_UNIDAD?

La tabla `sys_bitacora_auditoria` registra TODOS los eventos del sistema.

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | El ADMIN_UNIDAD no tiene acceso a la bitácora. Solo el SUPERADMIN la consulta. |
| B | El ADMIN_UNIDAD puede ver únicamente las acciones realizadas por usuarios de su unidad (filtrado por `unidad_medica_id`). |
| C | El ADMIN_UNIDAD puede ver todas las acciones en su unidad, incluyendo las realizadas por pacientes vinculados a ella. |
| D | El ADMIN_UNIDAD tiene vista completa de la bitácora (igual que SUPERADMIN) pero solo de eventos de su unidad. |

**Tu respuesta:** ___

---

## Sección 5 — Sesión y Navegación

### P9. ¿Puede el ADMIN_UNIDAD cambiar de unidad activa sin cerrar sesión?

Si un administrador gestiona dos unidades, ¿cómo cambia el contexto?

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | No. Debe cerrar sesión y volver a elegir la unidad en el selector del login. |
| B | Sí. Hay un selector de unidad en el menú de la app que emite un nuevo token sin cerrar sesión (llamada a `/auth/cambiar-unidad`). |
| C | Sí, pero solo si tiene exactamente una sesión activa (no múltiples pestañas abiertas). |

**Tu respuesta:** ___

---

### P10. ¿El ADMIN_UNIDAD puede también tener un rol operativo?

Por ejemplo: una enfermera jefe que administra la unidad Y también registra signos vitales.

**Opciones:**

| # | Comportamiento | Implicación |
|---|---------------|-------------|
| A | No. ADMIN_UNIDAD es un rol exclusivo; si una persona lo tiene, no puede tener ENFERMERA u otro rol en la misma unidad. | Más simple, menos confuso. |
| B | Sí. Una persona puede tener dos asignaciones activas en la misma unidad con distintos roles (ej: ADMIN_UNIDAD + ENFERMERA). El contexto de la sesión determina qué vistas se muestran. | Más flexible; requiere lógica extra en el frontend para mostrar menú combinado. |
| C | Sí, pero la UI solo muestra el menú del rol más elevado (ADMIN_UNIDAD). Para actuar como ENFERMERA debe cambiar el contexto de sesión explícitamente. | Compromiso entre ambos. |

**Tu respuesta:** ___

---

## Sección 6 — Dashboard del ADMIN_UNIDAD

### P11. ¿Qué métricas debe mostrar el dashboard principal?

Marca todas las que apliquen (puedes elegir varias):

| # | Métrica |
|---|---------|
| A | Total de personal activo en la unidad |
| B | Citas del día (programadas / atendidas / canceladas) |
| C | Citas de la semana |
| D | Pacientes nuevos del mes |
| E | Ocupación por servicio (% de citas completadas vs. capacidad) |
| F | Alertas de usuarios bloqueados que necesitan desbloqueo |
| G | Normativas/formularios que requieren actualización |
| H | Actividad reciente (últimas 10 acciones en la bitácora) |
| I | Comparativa mensual (atenciones este mes vs. mes anterior) |

**Tu respuesta (ej: A, B, F):** ___

---

## Sección 7 — Restricciones de Alcance (Confirmación)

### P12. ¿El ADMIN_UNIDAD puede ver o afectar datos de OTRAS unidades?

Confirma el aislamiento esperado:

**Opciones:**

| # | Comportamiento |
|---|---------------|
| A | Aislamiento total. No puede ver ningún dato de otras unidades, ni siquiera si el SUPERADMIN se lo intenta delegar. |
| B | Aislamiento por defecto, pero el SUPERADMIN puede otorgar permisos de "vista cruzada" en casos especiales (ej: red de clínicas de la misma organización). |

**Tu respuesta:** ___

---

## Resumen de Preguntas

| # | Tema | Respondida |
|---|------|-----------|
| P1 | ¿Qué puede crear sobre personal/usuarios? | ⬜ |
| P2 | ¿Puede resetear contraseñas? | ⬜ |
| P3 | ¿Puede revocar asignaciones? | ⬜ |
| P4 | ¿Puede adoptar normativas GIIS? | ⬜ |
| P5 | ¿Puede gestionar servicios de atención? | ⬜ |
| P6 | ¿Qué visibilidad tiene sobre pacientes? | ⬜ |
| P7 | ¿Puede gestionar la agenda? | ⬜ |
| P8 | ¿Qué parte de la bitácora puede ver? | ⬜ |
| P9 | ¿Puede cambiar de unidad sin logout? | ⬜ |
| P10 | ¿Puede tener rol operativo también? | ⬜ |
| P11 | ¿Qué métricas en el dashboard? | ⬜ |
| P12 | ¿Aislamiento total o delegable? | ⬜ |

---

## Próximos pasos

Una vez respondidas todas las preguntas, este documento pasará a estado
**✅ APROBADO** y se procederá con:

1. Diseño de las rutas y controladores del ADMIN_UNIDAD
2. Middleware de scope refinado para operaciones de admin
3. Dashboard + páginas de gestión en el frontend
4. Migración adicional si se requieren columnas nuevas (ej: `can_manage_admin` en la tabla puente)
